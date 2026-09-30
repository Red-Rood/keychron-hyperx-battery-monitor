import streamDeck, {
  action,
  SingletonAction,
  type WillAppearEvent,
  type WillDisappearEvent,
} from "@elgato/streamdeck";
import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";

type Device = "keychron" | "hyperx";
type Snapshot = {
  state?: string;
  name?: string;
  percent?: number | null;
  updatedAtUtc?: string;
};
type DisplayAction = {
  setImage(image: string): Promise<void>;
};

const visible = new Map<DisplayAction, Device>();
const localAppData = process.env.LOCALAPPDATA ?? join(homedir(), "AppData", "Local");
const dataDirectory = join(localAppData, "Red-Rood", "BatteryMonitor");
let refreshing = false;

function iconSvg(device: Device, snapshot?: Snapshot): string {
  const age = snapshot?.updatedAtUtc ? Date.now() - Date.parse(snapshot.updatedAtUtc) : Infinity;
  const ready = snapshot?.state?.toLowerCase() === "ready"
    && Number.isInteger(snapshot.percent)
    && (snapshot.percent ?? -1) >= 0
    && (snapshot.percent ?? 101) <= 100
    && age >= -60_000
    && age <= 180_000;
  const percent = ready ? `${snapshot?.percent}%` : "--";
  const status = ready ? "BATERIA" : "SIN DATOS";
  const fill = ready
    ? (snapshot!.percent! <= 20 ? "#e76f51" : snapshot!.percent! <= 50 ? "#e9c46a" : "#5abf90")
    : "#e9c46a";
  const glyph = device === "keychron"
    ? `<rect x="109" y="24" width="25" height="18" rx="3" fill="none" stroke="#65c4ec" stroke-width="3"/><path d="M114 30h3m4 0h3m4 0h3m-17 6h3m4 0h3m4 0h3" stroke="#65c4ec" stroke-width="2" stroke-linecap="round"/>`
    : `<path d="M110 38V31a12 12 0 0 1 24 0v7" fill="none" stroke="#65c4ec" stroke-width="3"/><rect x="107" y="34" width="7" height="14" rx="3" fill="#65c4ec"/><rect x="130" y="34" width="7" height="14" rx="3" fill="#65c4ec"/>`;
  const label = device === "keychron" ? "KEYCHRON V1 MAX" : "HYPERX CLOUD III";
  return `<svg xmlns="http://www.w3.org/2000/svg" width="144" height="144" viewBox="0 0 144 144"><rect x="4" y="4" width="136" height="136" rx="14" fill="#17242c"/><rect x="4" y="4" width="136" height="136" rx="14" fill="none" stroke="#344b56" stroke-width="2"/>${glyph}<text x="72" y="83" text-anchor="middle" fill="#fff" font-family="Segoe UI,Arial,sans-serif" font-size="43" font-weight="700">${percent}</text><text x="72" y="105" text-anchor="middle" fill="${fill}" font-family="Segoe UI,Arial,sans-serif" font-size="12" font-weight="700">${status}</text><text x="72" y="126" text-anchor="middle" fill="#a9bdc6" font-family="Segoe UI,Arial,sans-serif" font-size="9" letter-spacing="0.5">${label}</text></svg>`;
}

async function readSnapshot(device: Device): Promise<Snapshot | undefined> {
  try {
    const filename = device === "keychron" ? "keychron.json" : "hyperx.json";
    return JSON.parse(await readFile(join(dataDirectory, filename), "utf8")) as Snapshot;
  } catch {
    return undefined;
  }
}

async function refreshVisible(): Promise<void> {
  if (refreshing || visible.size === 0) return;
  refreshing = true;
  try {
    const snapshots = new Map<Device, Snapshot | undefined>();
    for (const device of new Set(visible.values())) {
      snapshots.set(device, await readSnapshot(device));
    }
    for (const [target, device] of visible) {
      await target.setImage(`data:image/svg+xml,${encodeURIComponent(iconSvg(device, snapshots.get(device)))}`);
    }
  } finally {
    refreshing = false;
  }
}

abstract class BatteryAction extends SingletonAction {
  protected constructor(private readonly device: Device) {
    super();
  }

  override onWillAppear(ev: WillAppearEvent): void {
    visible.set(ev.action as unknown as DisplayAction, this.device);
    void refreshVisible();
  }

  override onWillDisappear(ev: WillDisappearEvent): void {
    visible.delete(ev.action as unknown as DisplayAction);
  }
}

@action({ UUID: "com.red-rood.battery-monitor.keychron" })
class KeychronBatteryAction extends BatteryAction {
  constructor() {
    super("keychron");
  }
}

@action({ UUID: "com.red-rood.battery-monitor.hyperx" })
class HyperXBatteryAction extends BatteryAction {
  constructor() {
    super("hyperx");
  }
}

streamDeck.actions.registerAction(new KeychronBatteryAction());
streamDeck.actions.registerAction(new HyperXBatteryAction());
setInterval(() => void refreshVisible(), 5_000);
streamDeck.connect();
