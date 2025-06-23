import tkinter as tk
from tkinter import filedialog, messagebox, simpledialog, scrolledtext
from web3 import Web3
from eth_account import Account
from PIL import Image, ImageTk
import threading
import requests
from io import BytesIO
import webbrowser
import json

# Splash and logo
SPLASH_IMAGE_URL = "https://i.ibb.co/j9v2nvjT/new.png"
LOGO_URL = "https://i.ibb.co/j9v2nvjT/new.png"

default_networks = {
    "Base": {
        "rpc": "https://mainnet.base.org",
        "chain_id": 8453,
        "explorer": "https://basescan.org/tx/"
    },
    "Ethereum": {
        "rpc": "https://mainnet.infura.io/v3/YOUR_INFURA_KEY",
        "chain_id": 1,
        "explorer": "https://etherscan.io/tx/"
    },
    "BNB Chain": {
        "rpc": "https://bsc-dataseed.binance.org/",
        "chain_id": 56,
        "explorer": "https://bscscan.com/tx/"
    }
}

wallet_account = None  # Holds decrypted private key

def load_image_from_url(url, size):
    response = requests.get(url)
    img = Image.open(BytesIO(response.content)).resize(size, Image.Resampling.LANCZOS)
    return ImageTk.PhotoImage(img)

def show_splash():
    splash = tk.Toplevel()
    splash.overrideredirect(True)
    splash.geometry("300x300+600+300")
    splash.config(bg='white')
    img = load_image_from_url(SPLASH_IMAGE_URL, (250, 250))
    panel = tk.Label(splash, image=img, bg='white')
    panel.image = img # type: ignore
    panel.pack(expand=True)
    root.withdraw()
    splash.after(2500, lambda: (splash.destroy(), root.deiconify()))

def enable_copy_paste(widget):
    widget.bind("<Control-c>", lambda e: widget.event_generate('<<Copy>>'))
    widget.bind("<Control-v>", lambda e: custom_paste(e, widget))

def custom_paste(event, widget):
    try:
        widget.insert(tk.INSERT, widget.clipboard_get())
        return "break"
    except:
        return

def load_addresses_from_file():
    file_path = filedialog.askopenfilename(filetypes=[("Text Files", "*.txt")])
    if file_path:
        try:
            with open(file_path, "r") as file:
                addresses = [line.strip() for line in file.readlines() if line.strip()]
                addresses_text.delete("1.0", tk.END)
                addresses_text.insert(tk.END, "\n".join(addresses))
        except Exception as e:
            messagebox.showerror("Error", str(e))

def load_keystore():
    global wallet_account
    file_path = filedialog.askopenfilename(filetypes=[("Keystore Files", "*.json")])
    if not file_path:
        return
    try:
        with open(file_path, "r") as f:
            keystore = json.load(f)
        password = simpledialog.askstring("Wallet Password", "Enter wallet password:", show="*")
        if not password:
            return
        decrypted_key = Account.decrypt(keystore, password)
        wallet_account = Account.from_key(decrypted_key)
        private_key_entry.delete(0, tk.END)
        private_key_entry.insert(0, decrypted_key.hex())
        private_key_entry.config(state="disabled")
        messagebox.showinfo("Wallet Connected", f"Connected to: {wallet_account.address}")
    except Exception as e:
        messagebox.showerror("Error", str(e))

def send_funds():
    tx_output.delete("1.0", tk.END)
    private_key = private_key_entry.get().strip()
    try:
        amount = float(amount_entry.get().strip())
    except:
        messagebox.showerror("Error", "Invalid amount.")
        return
    network_name = selected_network.get()
    addresses = addresses_text.get("1.0", tk.END).strip().split("\n")
    if not private_key or not amount or not addresses:
        messagebox.showerror("Missing Info", "Fill all fields.")
        return

    def process_transactions():
        try:
            net_info = default_networks[network_name]
            web3 = Web3(Web3.HTTPProvider(net_info["rpc"]))
            if not web3.is_connected():
                messagebox.showerror("Connection Error", f"Can't connect to {network_name}")
                return
            account = web3.eth.account.from_key(private_key)
            nonce = web3.eth.get_transaction_count(account.address)
            for i, to_address in enumerate(addresses):
                tx = {
                    'nonce': nonce + i,
                    'to': to_address,
                    'value': web3.to_wei(amount, 'ether'),
                    'gas': 21000,
                    'gasPrice': web3.eth.gas_price,
                    'chainId': net_info["chain_id"]
                }
                signed_tx = web3.eth.account.sign_transaction(tx, private_key)
                tx_hash = web3.eth.send_raw_transaction(signed_tx.raw_transaction)
                link = net_info.get("explorer", "") + web3.to_hex(tx_hash)
                tx_output.insert(tk.END, f"{link}\n")
                tx_output.see(tk.END)
            messagebox.showinfo("Success", f"Funds sent to {len(addresses)} addresses.")
        except Exception as e:
            messagebox.showerror("Error", str(e))
    threading.Thread(target=process_transactions).start()

def add_network():
    name = simpledialog.askstring("Network Name", "Enter network name:")
    rpc = simpledialog.askstring("RPC URL", "Enter RPC URL:")
    chain_id = simpledialog.askinteger("Chain ID", "Enter Chain ID:")
    explorer = simpledialog.askstring("Explorer URL (optional)", "Enter explorer base URL")
    if name and rpc and chain_id:
        default_networks[name] = {"rpc": rpc, "chain_id": chain_id, "explorer": explorer or ""}
        network_menu['menu'].add_command(label=name, command=tk._setit(selected_network, name))
        messagebox.showinfo("Network Added", f"{name} added.")

def open_link(url):
    webbrowser.open_new(url)

# ==== UI ====
root = tk.Tk()
root.title("Multi Wallet Sender")
root.geometry("720x740")
root.configure(bg="#1e1e2f")

logo_img = load_image_from_url(LOGO_URL, (100, 100))
tk.Label(root, image=logo_img, bg="#1e1e2f").pack(pady=5)

style_entry = {"font": ("Arial", 12), "bg": "#f0f0f0", "relief": "flat"}

tk.Label(root, text="Private Key:", fg="white", bg="#1e1e2f", font=("Arial", 12, "bold")).pack()
private_key_entry = tk.Entry(root, width=50, show="*", **style_entry)
private_key_entry.pack(pady=2)

tk.Button(root, text="Connect Wallet (Keystore)", command=load_keystore, bg="#ffc107", fg="black", relief="flat").pack(pady=5)

tk.Label(root, text="Amount (ETH):", fg="white", bg="#1e1e2f", font=("Arial", 12, "bold")).pack()
amount_entry = tk.Entry(root, width=15, **style_entry)
amount_entry.pack(pady=2)

tk.Label(root, text="Select Network:", fg="white", bg="#1e1e2f", font=("Arial", 12, "bold")).pack()
selected_network = tk.StringVar(value="Base")
network_menu = tk.OptionMenu(root, selected_network, *default_networks.keys())
network_menu.config(width=20, font=("Arial", 10))
network_menu.pack(pady=5)

tk.Button(root, text="Add Custom Network", command=add_network, bg="#007acc", fg="white", relief="flat").pack(pady=4)

tk.Label(root, text="Recipient Addresses (one per line):", fg="white", bg="#1e1e2f", font=("Arial", 12, "bold")).pack()
addresses_text = tk.Text(root, height=4, width=70, font=("Arial", 10), bg="#fafafa")
addresses_text.pack(pady=2)

tk.Button(root, text="Load Addresses from .txt", command=load_addresses_from_file, bg="#44475a", fg="white", relief="flat").pack(pady=5)

tk.Button(root, text="Send Funds", command=send_funds, bg="#28a745", fg="white", font=("Arial", 12, "bold"), relief="flat").pack(pady=10)

tk.Label(root, text="Transaction Links:", fg="white", bg="#1e1e2f", font=("Arial", 12, "bold")).pack()
tx_output = scrolledtext.ScrolledText(root, height=6, width=70, font=("Arial", 10), bg="#f5f5f5")
tx_output.pack(pady=5)

tk.Label(root, text="هذا البرنامج أحد الأدوات المستخدمة في المجتمع العربي الأكبر في الويب3 BAG\nThis tool is part of the tools used in the largest Arabic Web3 community – BAG", fg="lightgray", bg="#1e1e2f", font=("Arial", 10)).pack(pady=10)

discord_icon = load_image_from_url("https://cdn-icons-png.flaticon.com/512/5968/5968756.png", (32, 32))
x_icon = load_image_from_url("https://i.ibb.co/XZh8MkDc/twitter.png", (32, 32))

links_frame = tk.Frame(root, bg="#1e1e2f")
links_frame.pack(pady=5)

tk.Label(links_frame, text="🌐", font=("Arial", 20), fg="white", bg="#1e1e2f", cursor="hand2").grid(row=0, column=0, padx=10)
tk.Label(links_frame, text="💻", font=("Arial", 20), fg="white", bg="#1e1e2f", cursor="hand2").grid(row=0, column=1, padx=10)
tk.Label(links_frame, image=discord_icon, bg="#1e1e2f", cursor="hand2").grid(row=0, column=2, padx=10)
tk.Label(links_frame, image=x_icon, bg="#1e1e2f", cursor="hand2").grid(row=0, column=3, padx=10)

enable_copy_paste(private_key_entry)
enable_copy_paste(amount_entry)
enable_copy_paste(addresses_text)

show_splash()
root.mainloop()
