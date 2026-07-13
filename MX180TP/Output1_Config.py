#!/usr/bin/env python3
"""
MX180TP Output 1 — Set voltage & current with automatic range selection.
Interactive loop lets the user turn Output 1 on/off and change V/I settings.
Communicates via TCP socket on port 9221.
"""

import socket
import time
import sys

# ── Configuration ──────────────────────────────────────────────
HOST = "192.168.0.98"
PORT = 9221
TIMEOUT = 5  # seconds

# Output 1 available ranges: (range_id, max_voltage, max_current)
# Ranges 4-7 disable Output 2.
OUTPUT1_RANGES = [
    (1, 30,  6),
    (2, 15, 10),
    (3, 60,  3),
    (4, 30, 12),   # disables O/P2
    (5, 15, 20),   # disables O/P2
    (6, 60,  6),   # disables O/P2
    (7, 120, 3),   # disables O/P2
]

RANGE_NAMES = {
    1: "30V/6A", 2: "15V/10A", 3: "60V/3A",
    4: "30V/12A", 5: "15V/20A", 6: "60V/6A", 7: "120V/3A"
}


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
    Prefers ranges 1-3 (which keep Output 2 alive) over 4-7.
    Among candidates with equal priority, picks the one with the smallest
    total headroom (max_v - voltage + max_i - current).
    """
    candidates = []
    for range_id, max_v, max_i in OUTPUT1_RANGES:
        if voltage <= max_v and current <= max_i:
            priority = 0 if range_id <= 3 else 1  # prefer standard ranges
            headroom = (max_v - voltage) + (max_i - current)
            candidates.append((priority, headroom, range_id, max_v, max_i))

    if not candidates:
        return None

    candidates.sort()
    _, _, best_id, best_v, best_i = candidates[0]
    return best_id, best_v, best_i


def get_output_status(sock: socket.socket) -> bool:
    """Return True if Output 1 is ON."""
    resp = send_query(sock, "OP1?")
    return resp.strip() == "1"


def print_status(sock: socket.socket) -> None:
    """Print current Output 1 status, voltage, current, and range."""
    on = get_output_status(sock)
    v_set = send_query(sock, "V1?")
    i_set = send_query(sock, "I1?")
    v_out = send_query(sock, "V1O?")
    i_out = send_query(sock, "I1O?")
    rng = int(send_query(sock, "VRANGE1?").strip())

    print(f"\n── Output 1 Status ──────────────────────")
    print(f"  State   : {'ON' if on else 'OFF'}")
    print(f"  Range   : {rng} ({RANGE_NAMES.get(rng, '?')})")
    print(f"  Set     : {v_set}  /  {i_set}")
    print(f"  Readback: {v_out}  /  {i_out}")
    print(f"─────────────────────────────────────────\n")


def do_set_voltage_current(sock: socket.socket) -> None:
    """Prompt for voltage and current, auto-select range, and apply."""
    try:
        voltage = float(input("  Enter desired voltage (V): "))
        current = float(input("  Enter desired current (A): "))
    except ValueError:
        print("  Invalid input. Please enter numeric values.")
        return

    if voltage < 0 or current < 0:
        print("  ERROR: Voltage and current must be positive.")
        return

    result = pick_best_range(voltage, current)
    if result is None:
        print(f"  ERROR: No Output 1 range can deliver {voltage} V / {current} A.")
        print("  Available ranges:")
        for rid, mv, mi in OUTPUT1_RANGES:
            print(f"    Range {rid}: {mv} V / {mi} A")
        return

    target_range_id, range_v, range_i = result
    current_range_id = int(send_query(sock, "VRANGE1?").strip())

    print(f"  Current range: {current_range_id} ({RANGE_NAMES.get(current_range_id, '?')})")
    print(f"  Target  range: {target_range_id} ({range_v}V/{range_i}A)")

    # ── Change range if needed ────────────────────────────
    if current_range_id != target_range_id:
        if target_range_id >= 4:
            confirm = input(f"  Range {target_range_id} will DISABLE Output 2. Continue? (y/n): ")
            if confirm.lower() != "y":
                print("  Aborted.")
                return

        # Range can only be changed when the output is OFF
        if get_output_status(sock):
            print("  Output 1 is ON — turning it OFF to change range ...")
            send_command(sock, "OP1 0")
            time.sleep(1)

        print(f"  Changing range to {target_range_id} ({range_v}V/{range_i}A) ...")
        send_command(sock, f"VRANGE1 {target_range_id}")
        time.sleep(2)

        verify_range = int(send_query(sock, "VRANGE1?").strip())
        if verify_range != target_range_id:
            print("  WARNING: Range change may not have completed.")
            print("  Check that residual terminal voltages are < 0.5 V and retry.")
            return
        else:
            print("  Range changed successfully.")
    else:
        print("  Range is already correct — no change needed.")

    # ── Set voltage and current ───────────────────────────
    print(f"  Setting Output 1 to {voltage} V, {current} A ...")
    send_command(sock, f"V1 {voltage}")
    send_command(sock, f"I1 {current}")

    v_set = send_query(sock, "V1?")
    i_set = send_query(sock, "I1?")
    print(f"  Confirmed set values -> {v_set}  /  {i_set}")


def do_turn_on(sock: socket.socket) -> None:
    """Turn Output 1 ON."""
    if get_output_status(sock):
        print("  Output 1 is already ON.")
    else:
        send_command(sock, "OP1 1")
        time.sleep(0.5)
        if get_output_status(sock):
            print("  ✅ Output 1 is now ON.")
        else:
            print("  WARNING: Output 1 did not turn on. Check for trip conditions.")


def do_turn_off(sock: socket.socket) -> None:
    """Turn Output 1 OFF."""
    if not get_output_status(sock):
        print("  Output 1 is already OFF.")
    else:
        send_command(sock, "OP1 0")
        time.sleep(0.5)
        if not get_output_status(sock):
            print("  ✅ Output 1 is now OFF.")
        else:
            print("  WARNING: Output 1 did not turn off.")


def print_menu():
    print("Commands:")
    print("  [1] Set voltage & current (auto-range)")
    print("  [2] Turn Output 1 ON")
    print("  [3] Turn Output 1 OFF")
    print("  [4] Show Output 1 status")
    print("  [q] Quit")


def main():
    # ── Connect to the MX180TP ─────────────────────────────────
    print(f"Connecting to MX180TP at {HOST}:{PORT} ...")
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(TIMEOUT)
    try:
        sock.connect((HOST, PORT))
    except (socket.timeout, ConnectionRefusedError, OSError) as e:
        print(f"Connection failed: {e}")
        sys.exit(1)

    idn = send_query(sock, "*IDN?")
    print(f"Connected — {idn}\n")

    try:
        print_status(sock)
        print_menu()

        while True:
            choice = input("\n> ").strip().lower()

            if choice == "1":
                do_set_voltage_current(sock)
            elif choice == "2":
                do_turn_on(sock)
            elif choice == "3":
                do_turn_off(sock)
            elif choice == "4":
                print_status(sock)
            elif choice == "q":
                # Safety: confirm if output is still on
                if get_output_status(sock):
                    leave_on = input("  Output 1 is ON. Leave it on? (y/n): ").strip().lower()
                    if leave_on != "y":
                        send_command(sock, "OP1 0")
                        print("  Output 1 turned OFF.")
                print("Goodbye.")
                break
            else:
                print("  Unknown command.")
                print_menu()

    except KeyboardInterrupt:
        print("\n\nInterrupted.")
    finally:
        sock.close()
        print("Socket closed.")


if __name__ == "__main__":
    main()