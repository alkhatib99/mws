from flask import Flask, request, jsonify
from flask_cors import CORS
from eth_account import Account, messages
import json

app = Flask(__name__)
CORS(app)

@app.route("/")
def home():
    return jsonify({
        "message": "Welcome to api.alkhatibcrypto.xyz",
        "next_step": "Connect your wallet to begin."
    })

@app.route("/ping", methods=["GET"])
def ping():
    return jsonify({"status": "ok", "message": "API is running at api.alkhatibcrypto.xyz"})

@app.route("/verify_wallet", methods=["POST"])
def verify_wallet():
    data = request.get_json()
    address = data.get("address")
    message = data.get("message")
    signature = data.get("signature")

    if not address or not message or not signature:
        return jsonify({"error": "Missing fields: address, message, or signature"}), 400

    try:
        message_hash = messages.encode_defunct(text=message)
        recovered_address = Account.recover_message(message_hash, signature=signature)
        is_valid = recovered_address.lower() == address.lower()
        return jsonify({
            "valid": is_valid,
            "recovered": recovered_address,
            "original": address
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/decrypt_keystore", methods=["POST"])
def decrypt_keystore():
    data = request.get_json()
    keystore = data.get("keystore")
    password = data.get("password")

    if not keystore or not password:
        return jsonify({"error": "Missing keystore or password"}), 400

    try:
        private_key = Account.decrypt(keystore, password)
        account = Account.from_key(private_key)
        return jsonify({
            "address": account.address,
            "private_key": private_key.hex()
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/log_transaction", methods=["POST"])
def log_transaction():
    data = request.get_json()
    tx_hash = data.get("tx_hash")
    network = data.get("network")
    sender = data.get("from")
    recipient = data.get("to")
    amount = data.get("amount")

    if not all([tx_hash, network, sender, recipient, amount]):
        return jsonify({"error": "Missing one or more required fields"}), 400

    print("Transaction logged:", data)
    return jsonify({"status": "logged", "data": data})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
