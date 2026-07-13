#!/usr/bin/env python3
"""
MX180TP Output 2 — Set voltage & current with automatic range selection.
Communicates via TCP socket on port 9221.
"""

import socket
import time
import sys

# ── Configuration ──────────────────────────────────────────────
HOST = "192.168.0.98"
PORT = 9221
TIMEOUT = 5  # seconds

# Output 2 available ranges: (range_id, max_voltage, max_current)
OUTPUT2_RANGES = [
    (1, 30,  6),
    (2, 15, 10),
    (3, 60,  3),
]

# Output 1 extended ranges (4-7) that disable Output 2
OUTPUT1_EXTENDED_RANGES = {4, 5, 6, 7}


def send_command(sock: socket.socket, cmd: str) -> None:
    """Send a command (no response expected)."""
    sock.sendall((cmd + "\n").encode())
    time.sleep(0.3)


def send_query(sock: socket.socket, query: str) -> str:
    """Send a query and return the response string."""
    sock.sendall((query + "\n").encode())
    time.sleep(0.3)
    response = sock.recv(1024).decode().strip()
    return response


def pick_best_range(voltage: float, current: float):
    """
    Return the range_id of the smallest range that fits the requested V and I.
    Picks the one with the smallest total headroom (tightest fit).
    """
    candidates = []
    for range_id, max_v, max_i in OUTPUT2_RANGES:
        if voltage <= max_v and current <= max_i:
            headroom = (max_v - voltage) + (max_i - current)
            candidates.append((headroom, range_id, max_v, max_i))

    if not candidates:
        return None

    candidates.sort()  # least headroom first = tightest fit
    _, best_id, best_v, best_i = candidates[0]
    return best_id, best_v, best_i


def main():
    # ── Get desired voltage and current from the user ──────────
    try:
        voltage = float(input("Enter desired voltage (V) for Output 2: "))
        current = float(input("Enter desired current (A) for Output 2: "))
    except ValueError:
        print("Invalid input. Please enter numeric values.")
        sys.exit(1)

    # ── Validate against absolute Output 2 limits ──────────────
    if voltage < 0 or current < 0:
        print("ERROR: Voltage and current must be positive.")
        sys.exit(1)

    # ── Find the best matching range ───────────────────────────
    result = pick_best_range(voltage, current)
    if result is None:
        print(f"ERROR: No Output 2 range can deliver {voltage} V / {current} A.")
        print("Output 2 available ranges:")
        for rid, mv, mi in OUTPUT2_RANGES:
            print(f"  Range {rid}: {mv} V / {mi} A")
        sys.exit(1)

    target_range_id, range_v, range_i = result

    # ── Connect to the MX180TP ─────────────────────────────────
    print(f"\nConnecting to MX180TP at {HOST}:{PORT} ...")
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(TIMEOUT)
    try:
        sock.connect((HOST, PORT))
    except (socket.timeout, ConnectionRefusedError, OSError) as e:
        print(f"Connection failed: {e}")
        sys.exit(1)

    print("Connected.\n")

    try:
        # ── Identify the instrument ───────────────────────────
        idn = send_query(sock, "*IDN?")
        print(f"Instrument: {idn}")

        # ── Check if Output 1 is in an extended range (disables O/P2) ──
        o1_range_raw = send_query(sock, "VRANGE1?")
        o1_range_id = int(o1_range_raw.strip())
        if o1_range_id in OUTPUT1_EXTENDED_RANGES:
            o1_range_names = {
                4: "30V/12A", 5: "15V/20A", 6: "60V/6A", 7: "120V/3A"
            }
            print(f"ERROR: Output 1 is currently in extended range {o1_range_id} "
                  f"({o1_range_names.get(o1_range_id, '?')}).")
            print("Output 2 is DISABLED when Output 1 uses an extended range.")
            print("Switch Output 1 to range 1, 2, or 3 first, then retry.")
            sys.exit(1)

        # ── Read current Output 2 range ───────────────────────
        current_range_raw = send_query(sock, "VRANGE2?")
        current_range_id = int(current_range_raw.strip())
        range_names = {1: "30V/6A", 2: "15V/10A", 3: "60V/3A"}
        print(f"Current range: {current_range_id} ({range_names.get(current_range_id, '?')})")
        print(f"Target  range: {target_range_id} ({range_v}V/{range_i}A)")

        # ── Change range if needed ────────────────────────────
        if current_range_id != target_range_id:
            # Range can only be changed when the output is OFF
            op_status = send_query(sock, "OP2?")
            if op_status.strip() == "1":
                print("Output 2 is ON — turning it OFF to change range ...")
                send_command(sock, "OP2 0")
                time.sleep(1)  # allow residual voltage to decay

            print(f"Changing range to {target_range_id} ({range_v}V/{range_i}A) ...")
            send_command(sock, f"VRANGE2 {target_range_id}")
            time.sleep(2)  # range switching can take a moment

            # Verify the range change
            verify_range = send_query(sock, "VRANGE2?")
            if int(verify_range.strip()) != target_range_id:
                print("WARNING: Range change may not have completed.")
                print("Check that residual terminal voltages are < 0.5 V and retry.")
            else:
                print("Range changed successfully.")
        else:
            print("Range is already correct — no change needed.")

        # ── Set voltage and current ───────────────────────────
        print(f"\nSetting Output 2 to {voltage} V, {current} A ...")
        send_command(sock, f"V2 {voltage}")
        send_command(sock, f"I2 {current}")

        # ── Read back and confirm ─────────────────────────────
        v_set = send_query(sock, "V2?")
        i_set = send_query(sock, "I2?")
        print(f"Confirmed set values -> {v_set}  /  {i_set}")

        print("\n✅ Done. Turn on Output 2 manually when ready (front panel or OP2 1).")

    finally:
        sock.close()
        print("Socket closed.")


if __name__ == "__main__":
    main()