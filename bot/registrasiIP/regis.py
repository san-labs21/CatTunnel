import telebot
from telebot import types
from datetime import datetime, timedelta
import sqlite3
import requests
import base64
import json
import zipfile
import os
import threading
import time

# === Konfigurasi ===
TOKEN = '7613051160:AAEnIVbNM4uaH1NvXN5Cct_iyjF7wvvcBAI'  # Ganti dengan token bot kamu
ADMIN_ID = 576495165  # Ganti dengan chat ID kamu

# Konfigurasi GitHub
GITHUB_TOKEN = "GITHUB_TOKEN_MU"  # ⚠️ Ganti dengan token GitHub kamu
REPO_OWNER = "san-labs21"
REPO_NAME = "CatTunnel"
FILE_PATH = "permission"
BRANCH = "main"

bot = telebot.TeleBot(TOKEN)

# === Koneksi ke Database SQLite ===
DB_NAME = 'user_balance.db'

def init_db():
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS users (
                 chat_id INTEGER PRIMARY KEY,
                 username TEXT,
                 balance INTEGER DEFAULT 0,
                 status TEXT DEFAULT "Biasa",
                 status_expired TEXT DEFAULT NULL)''')  # Saldo default 0
    conn.commit()
    conn.close()

def get_user_data(chat_id):
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("SELECT * FROM users WHERE chat_id=?", (chat_id,))
    user = c.fetchone()
    conn.close()
    return user

def add_or_update_user(chat_id, username, balance=0):
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("INSERT OR IGNORE INTO users (chat_id, username, balance) VALUES (?, ?, ?)",
              (chat_id, username, balance))
    c.execute("UPDATE users SET username=? WHERE chat_id=?", (username, chat_id))
    conn.commit()
    conn.close()

def update_balance(chat_id, new_balance):
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("UPDATE users SET balance=? WHERE chat_id=?", (new_balance, chat_id))
    conn.commit()
    conn.close()

def update_status(chat_id, new_status, duration_days=30):
    expired_date = (datetime.now() + timedelta(days=duration_days)).strftime("%Y-%m-%d %H:%M:%S")
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("UPDATE users SET status=?, status_expired=? WHERE chat_id=?", 
              (new_status, expired_date, chat_id))
    conn.commit()
    conn.close()

def check_and_reset_expired_statuses():
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("UPDATE users SET status='Biasa', status_expired=NULL WHERE status!='Biasa' AND status_expired < ?", (now,))
    conn.commit()
    conn.close()

def get_all_users():
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("SELECT chat_id, username, balance, status, status_expired FROM users")
    users = c.fetchall()
    conn.close()
    return users

# === Fungsi Baca File Permission dari GitHub ===
def baca_permission():
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/contents/{FILE_PATH}"
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }
    res = requests.get(url, headers=headers)
    if res.status_code != 200:
        print("Error membaca file:", res.json())
        return []
    content = base64.b64decode(res.json()['content']).decode()
    lines = content.strip().splitlines()
    data = []
    for line in lines:
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        ip = parts[0]
        date_str = parts[1]
        data.append((ip, date_str))
    return data

# === Fungsi Tulis File Permission ke GitHub ===
def tulis_permission(data):
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/contents/{FILE_PATH}"
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }
    # Ambil SHA file lama
    res = requests.get(url, headers=headers)
    sha = res.json().get('sha') if res.status_code == 200 else None
    # Format konten baru
    content = '\n'.join([f"{ip} {date}" for ip, date in data])
    payload = {
        "message": "Update permission via bot",
        "content": base64.b64encode(content.encode()).decode(),
        "branch": BRANCH
    }
    if sha:
        payload["sha"] = sha
    res = requests.put(url, headers=headers, data=json.dumps(payload))
    if res.status_code == 200:
        return True
    else:
        print("Error menulis file:", res.json())
        return False

# === Fungsi Tampilkan Panel Pengguna ===
def tampilkan_panel(chat_id, user_id, message_id=None):
    user = bot.get_chat(user_id)
    username = user.username or "-"
    chatid = user.id
    add_or_update_user(chatid, username)
    data = get_user_data(chatid)
    chatid_db, uname, balance, status, expired = data
    now = datetime.now()
    if expired:
        exp_date = datetime.strptime(expired, "%Y-%m-%d %H:%M:%S")
        remaining_days = (exp_date - now).days
        if remaining_days < 0:
            status = "Biasa"
            update_status(chatid, "Biasa", 0)  # Reset status
            remaining_days = 0
        expired_str = f"({remaining_days} {'Days' if remaining_days != 1 else 'Day'} Left)"
    else:
        expired_str = ""
    # Judul berdasarkan apakah user adalah admin
    if user_id == ADMIN_ID:
        title = "🟢 PANEL ADMIN SCRIPT"
    else:
        title = "🟢 PANEL MEMBER SCRIPT"
    panel_text = f"{title}\n"
    panel_text += f"ChatID     : `{chatid}`\n"
    panel_text += f"Username   : @{uname}\n"
    if status == "VIP":
        panel_text += f"Status     : {status} {expired_str}\n"
        panel_text += f"Saldo      : Unlimited\n"
    else:
        panel_text += f"Status     : {status} {expired_str}\n"
        panel_text += f"Saldo      : Rp {balance:,}\n"
    markup = types.InlineKeyboardMarkup(row_width=2)
    markup.add(
        types.InlineKeyboardButton("➕REGISTER IP", callback_data='regis_ip'),
        types.InlineKeyboardButton("🔁CHANGE IP", callback_data='change_ip'),
        types.InlineKeyboardButton("⏳RENEW IP", callback_data='renew_ip')
    )
    if user_id == ADMIN_ID:
        markup.add(types.InlineKeyboardButton("🔮ADMIN", callback_data='admin_menu'))
    
    if message_id:
        try:
            bot.edit_message_text(
                chat_id=chat_id,
                message_id=message_id,
                text=panel_text,
                reply_markup=markup,
                parse_mode="Markdown"
            )
        except Exception as e:
            print(f"[ERROR] Tidak bisa edit pesan: {e}")
    else:
        bot.send_message(chat_id, panel_text, reply_markup=markup, parse_mode="Markdown")

# === Handler untuk /start ===
@bot.message_handler(commands=['start'])
def send_welcome(message):
    tampilkan_panel(message.chat.id, message.from_user.id)

# === Callback Query Handler ===
@bot.callback_query_handler(func=lambda call: True)
def handle_query(call):
    chat_id = call.message.chat.id
    user_id = call.from_user.id
    if call.data == 'regis_ip':
        msg = bot.send_message(chat_id, "Kirimkan IP dan jumlah hari (contoh: 192.168.1.10 30):")
        bot.register_next_step_handler(msg, proses_regis_ip)
    elif call.data == 'change_ip':
        msg = bot.send_message(chat_id, "Kirimkan IP Lama dan IP Baru (contoh: 192.168.1.10 192.168.1.11):")
        bot.register_next_step_handler(msg, proses_change_ip)
    elif call.data == 'renew_ip':
        msg = bot.send_message(chat_id, "Kirimkan IP dan jumlah hari untuk perpanjang (contoh: 192.168.1.10 30):")
        bot.register_next_step_handler(msg, proses_renew_ip)
    elif call.data == 'admin_menu':
        if chat_id != ADMIN_ID:
            bot.answer_callback_query(call.id, "Akses ditolak! Anda bukan admin.", show_alert=True)
            return

        markup = types.InlineKeyboardMarkup()
        markup.add(
            types.InlineKeyboardButton("💰Tambah Saldo", callback_data='admin_tambah_saldo'),
            types.InlineKeyboardButton("👑Tambah VIP", callback_data='admin_tambah_vip'),
            types.InlineKeyboardButton("💎Tambah Reseller", callback_data='admin_tambah_reseller'),
            types.InlineKeyboardButton("⛔Reset Status", callback_data='admin_reset_status')
        )
        markup.add(
            types.InlineKeyboardButton("🗑️Hapus User", callback_data='admin_hapus_user'),
            types.InlineKeyboardButton("🗂️List User", callback_data='admin_lihat_semua')
        )
        markup.add(
            types.InlineKeyboardButton("⬅️ Back", callback_data='back_to_panel')  # Tombol kembali
        )

        # Edit pesan lama menjadi menu admin
        try:
            bot.edit_message_text(
                chat_id=chat_id,
                message_id=call.message.message_id,
                text="🖥️ MENU ADMIN CONTROL :",
                reply_markup=markup
            )
        except Exception as e:
            print(f"[ERROR] Tidak bisa edit pesan: {e}")
    elif call.data == 'back_to_panel':
        tampilkan_panel(chat_id, user_id)
        try:
            bot.delete_message(chat_id, call.message.message_id)  # Hapus menu admin
        except:
            pass
    elif call.data == 'admin_tambah_saldo':
        msg = bot.send_message(chat_id, "Kirimkan chat ID, jumlah saldo (contoh: 123456789 50000):")
        bot.register_next_step_handler(msg, proses_admin_tambah_saldo)
    elif call.data == 'admin_tambah_vip':
        msg = bot.send_message(chat_id, "Kirimkan Chat ID user untuk jadikan VIP:")
        bot.register_next_step_handler(msg, proses_admin_tambah_vip)
    elif call.data == 'admin_tambah_reseller':
        msg = bot.send_message(chat_id, "Kirimkan Chat ID user untuk jadikan Reseller:")
        bot.register_next_step_handler(msg, proses_admin_tambah_reseller)
    elif call.data == 'admin_reset_status':
        msg = bot.send_message(chat_id, "Kirimkan Chat ID user untuk reset status:")
        bot.register_next_step_handler(msg, proses_admin_reset_status)
    elif call.data == 'admin_hapus_user':
        msg = bot.send_message(chat_id, "Kirimkan chat ID user yang ingin dihapus:")
        bot.register_next_step_handler(msg, proses_admin_hapus_user)
    elif call.data == 'admin_lihat_semua':
        users = get_all_users()
        if not users:
            bot.send_message(chat_id, "Belum ada user yang terdaftar.")
            return
        list_users = "\n".join([f"`{uid}` | @{uname} | Rp {bal:,} | {stat} {exp or ''}" for uid, uname, bal, stat, exp in users])
        bot.send_message(chat_id, f"Daftar User:\n{list_users}", parse_mode="Markdown")

# === Proses Input ===
def proses_regis_ip(message):
    try:
        ip, days = message.text.strip().split()
        days = int(days)
        user_id = message.from_user.id
        user_data = get_user_data(user_id)
        current_balance = user_data[2]
        status = user_data[3]

        if status == 'Biasa':
            cost = days * 333
        elif status == 'Reseller':
            cost = days * 250
        else:
            cost = 0  # VIP

        if status in ['Biasa', 'Reseller'] and current_balance < cost:
            bot.reply_to(message, f"Saldo tidak mencukupi. Diperlukan: Rp {cost:,}")
            tampilkan_panel(message.chat.id, user_id)
            return

        exp_date = (datetime.now() + timedelta(days=days)).strftime("%Y-%m-%d")
        data = baca_permission()
        data.append((ip, exp_date))
        if tulis_permission(data):
            if status != 'VIP':
                new_balance = current_balance - cost
                update_balance(user_id, new_balance)
            bot.reply_to(
                message,
                f"✅ Registrasi IP Succes\n\n"
                f"Biaya : Rp {cost:,}\n"
                f"❗ Jika Ada Eror Silahkan Install Ulang\n\n"
                f"Link Install :\n"
                f"`wget -q https://raw.githubusercontent.com/san-labs21/san-tunnel/main/san-tunnel.sh && bash san-tunnel.sh`",
                parse_mode="Markdown"
            )
        
    except:
        bot.reply_to(message, "Format salah. Contoh: 192.168.1.10 30")

def proses_change_ip(message):
    try:
        old_ip, new_ip = message.text.strip().split()
        data = baca_permission()
        found = False
        for i, (ip, date) in enumerate(data):
            if ip == old_ip:
                data[i] = (new_ip, date)
                found = True
                break
        if not found:
            bot.reply_to(message, "IP lama tidak ditemukan.")
            return
        if tulis_permission(data):
            bot.reply_to(
                message,
                f"✅ Changed IP Succes\n"
                f"IP Lama : `{old_ip}` \n"
                f"IP Baru : `{new_ip}`\n"
                f" Thanks Fo Using This Script",
                parse_mode="Markdown"
            )
           
        
    except:
        bot.reply_to(message, "Format salah. Contoh: 192.168.1.10 192.168.1.11")

def proses_renew_ip(message):
    try:
        ip, days = message.text.strip().split()
        days = int(days)
        user_id = message.from_user.id
        user_data = get_user_data(user_id)
        current_balance = user_data[2]
        status = user_data[3]

        if status == 'Biasa':
            cost = days * 333
        elif status == 'Reseller':
            cost = days * 250
        else:
            cost = 0  # VIP

        if status in ['Biasa', 'Reseller'] and current_balance < cost:
            bot.reply_to(message, f"Saldo tidak mencukupi. Diperlukan: Rp {cost:,}")
            tampilkan_panel(message.chat.id, user_id)
            return

        exp_date = (datetime.now() + timedelta(days=days)).strftime("%Y-%m-%d")
        data = baca_permission()
        found = False
        for i, (ip_file, date) in enumerate(data):
            if ip_file == ip:
                data[i] = (ip, exp_date)
                found = True
                break
        if not found:
            bot.reply_to(message, "IP tidak ditemukan dalam daftar.")
            return
        if tulis_permission(data):
            if status != 'VIP':
                new_balance = current_balance - cost
                update_balance(user_id, new_balance)
            bot.reply_to(
                message,
                f"✅ Renewed IP Succes\n"
                f"Tanggal IP : `{ip}`\n"
                f"diperbarui hingga : `{exp_date}`\n"
                f"Biaya : Rp {cost:,}",
                parse_mode="Markdown"
            )
        
    except:
        bot.reply_to(message, "Format salah. Contoh: 192.168.1.10 30")

# === Fungsi Admin ===
def proses_admin_tambah_saldo(message):
    try:
        chat_id_str, amount_str = message.text.strip().split()
        chat_id_user = int(chat_id_str)
        amount = int(amount_str)
        user = get_user_data(chat_id_user)
        if not user:
            bot.reply_to(message, "User tidak ditemukan.")
            return
        new_balance = user[2] + amount
        update_balance(chat_id_user, new_balance)
        bot.reply_to(
                message,
                f"✅ Tambahan Saldo Succes\n"
                f"User : `{chat_id_user}`\n"
                f"Saldo : Rp {amount:,}\n"
                f"Thanks For Using This Script",
                parse_mode="Markdown"
        )
        
        
    except:
        bot.reply_to(message, "Format salah. Contoh: 123456789 50000")

def proses_admin_tambah_vip(message):
    try:
        chat_id_user = int(message.text.strip())
        user = get_user_data(chat_id_user)
        if not user:
            bot.reply_to(message, "User tidak ditemukan.")
            return
        update_status(chat_id_user, "VIP")
        bot.reply_to(
                message,
                f"✅ Registrasi User VIP Succes\n"
                f"User : `{chat_id_user}`\n"
                f"Telah Di Upgrade Menjadi VIP Selama 1 Bulan",
                parse_mode="Markdown"
        )
        
    except:
        bot.reply_to(message, "Format salah. Masukkan chat ID yang valid.")

def proses_admin_tambah_reseller(message):
    try:
        chat_id_user = int(message.text.strip())
        user = get_user_data(chat_id_user)
        if not user:
            bot.reply_to(message, "User tidak ditemukan.")
            return
        update_status(chat_id_user, "Reseller")
        bot.reply_to(
                message,
                f"✅ Registrasi User Reseller Succes\n"
                f"User : `{chat_id_user}`\n"
                f"Telah Di Upgrade Menjadi Reseller Selama 1 Bulan",
                parse_mode="Markdown"
        )
        
    except:
        bot.reply_to(message, "Format salah. Masukkan chat ID yang valid.")
        

def proses_admin_reset_status(message):
    try:
        chat_id_user = int(message.text.strip())
        conn = sqlite3.connect(DB_NAME)
        c = conn.cursor()
        c.execute("UPDATE users SET status='Biasa', status_expired=NULL WHERE chat_id=?", (chat_id_user,))
        conn.commit()
        conn.close()
        bot.reply_to(
                message,
                f"✅ Reset User Status Succes\n"
                f"User : `{chat_id_user}`\n"
                f"Telah Di Downgrade Menjadi User Biasa",
                parse_mode="Markdown"
        )
        
        bot.reply_to(message, f"Status user `{chat_id_user}` berhasil direset menjadi Biasa.", parse_mode="Markdown")
        
    except:
        bot.reply_to(message, "Format salah. Masukkan chat ID yang valid.")

def proses_admin_hapus_user(message):
    try:
        chat_id_user = int(message.text.strip())
        conn = sqlite3.connect(DB_NAME)
        c = conn.cursor()
        c.execute("DELETE FROM users WHERE chat_id=?", (chat_id_user,))
        conn.commit()
        conn.close()
        bot.reply_to(message, f"User `{chat_id_user}` berhasil dihapus dari database.", parse_mode="Markdown")
        tampilkan_panel(message.chat.id, message.from_user.id)
    except:
        bot.reply_to(message, "Format salah. Masukkan chat ID yang valid.")

# === Backup Otomatis ===
BACKUP_FOLDER = "backup"
def kirim_backup_ke_admin():
    try:
        if not os.path.exists(BACKUP_FOLDER):
            os.makedirs(BACKUP_FOLDER)
        waktu_sekarang = datetime.now().strftime("%Y%m%d_%H%M%S")
        zip_name = f"{BACKUP_FOLDER}/backup_{waktu_sekarang}.zip"
        with zipfile.ZipFile(zip_name, 'w') as zipf:
            zipf.write(DB_NAME)
        with open(zip_name, 'rb') as f:
            bot.send_document(ADMIN_ID, f, caption=f"📦 Backup: {os.path.basename(zip_name)}")
        print(f"[INFO] Backup berhasil dikirim: {zip_name}")
    except Exception as e:
        print(f"[ERROR] Gagal mengirim backup: {e}")

def jalankan_backup_otomatis():
    while True:
        kirim_backup_ke_admin()
        time.sleep(6 * 60 * 60)  # 6 jam

threading.Thread(target=jalankan_backup_otomatis, daemon=True).start()

# === Restore dari Upload ZIP ===
@bot.message_handler(content_types=['document'])
def handle_restore(message):
    if message.from_user.id != ADMIN_ID:
        bot.reply_to(message, "Anda tidak memiliki akses untuk restore.")
        return
    try:
        file_id = message.document.file_id
        file_info = bot.get_file(file_id)
        downloaded_file = bot.download_file(file_info.file_path)
        zip_path = "temp_backup.zip"
        with open(zip_path, 'wb') as f:
            f.write(downloaded_file)
        with zipfile.ZipFile(zip_path, 'r') as zipf:
            zipf.extractall(".")
        os.remove(zip_path)
        bot.reply_to(message, "Database berhasil direstore dari backup.", parse_mode="Markdown")
    except Exception as e:
        bot.reply_to(message, f"Gagal melakukan restore: {e}")

# === Jadwal Pengecekan Expired ===
def auto_check_expired():
    while True:
        check_and_reset_expired_statuses()
        time.sleep(3600)  # Setiap jam

threading.Thread(target=auto_check_expired, daemon=True).start()

# === Jalankan Bot ===
print("Bot sedang berjalan...")
init_db()
bot.polling(none_stop=True)
