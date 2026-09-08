import type { Hook, LiveSocketInstanceInterface } from "phoenix_live_view";

// --- Public API ---

export interface LLVConfig {
  /** Paths to compiled Wasm bundle files. Defaults to `["wasm/bundle.avm"]` */
  bundlePaths?: string[];
  /** Enable Popcorn debug logging */
  debug?: boolean;
  /** Callback for raw Popcorn messages */
  eventHandler?: (msg: unknown) => void;
  /**
   * Override LLV's default navigation handler.
   * Called instead of `liveSocket.historyPatch` when an LLV view calls `push_patch`.
   * Pass a custom function to take full control of navigation.
   */
  onNavigate?: (href: string, replace: boolean) => void;
  /**
   * Hooks available to local views (`phx-hook` in their templates).
   * Independent of the host LiveSocket's hooks — pass the same object to
   * both if hooks are shared.
   */
  hooks?: Record<string, Hook>;
}

// --- Internal Phoenix types ---

/** A raw Phoenix channel frame as it crosses the (fake) transport. */
export interface TransportFrame {
  topic: string;
  event: string;
  payload: unknown;
  ref: string | null;
  join_ref: string | null;
}

export interface PointerData {
  clientX: number;
  clientY: number;
  pageX: number;
  pageY: number;
  screenX: number;
  screenY: number;
  movementX: number;
  movementY: number;
  button: number;
  buttons: number;
  altKey: boolean;
  ctrlKey: boolean;
  metaKey: boolean;
  shiftKey: boolean;
  rect: { top: number; left: number; width: number; height: number };
}

export interface LLVServerEventDetail {
  view: string;
  payload: unknown;
}

/**
 * A mounted LocalLiveViewEventBus hook instance: the host-side channel used
 * by __llvPushServer.
 */
export interface EventBusHook {
  el: HTMLElement;
  pushEvent(event: string, payload: Record<string, unknown>): Promise<unknown>;
}

/**
 * LiveSocket members missing from LV's published LiveSocketInstanceInterface,
 * which LLV accesses via type-cast. All are private API except isConnected —
 * a public runtime method their TS types simply don't declare.
 */
interface PhxLiveSocketInternals {
  isConnected(): boolean;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  hooks: Record<string, any>;
  debounce(el: Element, event: Event, eventType: string, callback: () => void): unknown;
  roots: Record<string, { channel: { leave(): unknown } }>;
  pushHistoryPatch(
    event: Event | { isTrusted: boolean; type: string },
    href: string,
    linkState: string,
    targetEl: Element | null,
  ): void;
}

/** Public LiveSocket interface extended with Phoenix internals accessed by LLV. */
export type LLVSocket = LiveSocketInstanceInterface & PhxLiveSocketInternals;

declare global {
  interface Window {
    __llvPopcornTransportPush?: (frame: TransportFrame) => void;
    __llvSync?: (id: string, eventName: string, payload: Record<string, unknown>) => void;
    __llvPushServer?: (llvId: string, event: string, payload: Record<string, unknown>) => void;
  }
}
