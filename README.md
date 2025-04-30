<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.6+-blue?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Riverpod-State%20Management-green?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/API-Connected-brightgreen?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Mobile-Admin%20App-purple?style=for-the-badge"/>
</p>

<h1 align="center">📦 Craftz Admin App</h1>
<h3 align="center">A mobile inventory and product management app built in Flutter</h3>

<p align="center">
  <em>Real-time inventory management for the Craftz Store backend</em>
</p>

---

## 📲 About the Project

This is the **administration mobile app** for Craftz Store, designed to manage product inventory, monitor stock levels, and provide access control through secure login sessions.

- 🔐 Authenticated login using JWT
- 📦 Product listing and inventory data
- 🛒 Low-stock alerts and restock planning
- 🧠 State management with Riverpod
- 📲 Built using Flutter + Dart

---

## 🧑‍💻 Tech Stack

| Tool | Role |
|------|------|
| **Flutter** | Mobile app framework |
| **Dart** | Programming language |
| **Riverpod** | State management |
| **HTTP** | API consumption |
| **SharedPreferences** | Local storage for tokens |
| **Flutter DotEnv** | Environment config |
| **Flutter Slidable** | Swipeable lists for UX |
| **MongoDB (via API)** | Database source |

---

## 🌐 API Integration

The app consumes the Craftz API backend deployed via **Render**, using environment-controlled URLs.

```env
API_URL=https://craftz-api.onrender.com
```

The following endpoints are currently consumed:
- POST /auth/login → Login and store JWT
- GET /api/productos → Fetch product inventory
- [Planned:] POST /api/ventas → Submit sales
- [Planned:] GET /api/categorias → Load categories/subcategories

## 🧠 State Management
The app uses Flutter Riverpod to manage state for:
- ✅ User session and auth token
- 🧺 Product inventory list
- 📉 Low-stock or out-of-stock alerts
- 🔄 API response tracking and refresh logic
This ensures clean separation of logic and reactivity across screens.

## 💡 UI/UX Features
| Feature | Description |
|---------|-------------|
| **🔒 Splash screen** |	Custom splash with session validation |
| **🧾 Login screen** |	Email/password login |
| **📦 Inventory screen** | Product grid with variants |
| **⚠️ Alerts screen** | List of low-stock products |
| **🎨 Custom theme** | Branded color scheme + Eras fonts |
| **📱 Adaptive UI** | Designed for tablets and phones |

## 🚀 Getting Started
```
To run this app locally:
git clone https://github.com/yourusername/craftz_app.git
cd craftz_app
flutter pub get
flutter run
```
Make sure to add a .env file with your API config:
```
API_URL=https://craftz-api.onrender.com
```

## 🎨 Theme Preview
- Splash	
- Login
- Inventory

> Splash	Login	Inventory

## 🔜 Next Features
- Add/Edit/Delete products from the app
- Barcode scanner for stock updates
- Sales registration from mobile
- Role-based access control

🛠️ Powered By
```
flutter: ^3.6.0
flutter_riverpod: ^2.6.1
http: ^1.0.0
shared_preferences: ^2.4.0
flutter_dotenv: ^5.0.2
flutter_slidable: ^4.0.0
```

## 👨‍💻 Author
Developed by Francisco García Solís.
🚀 Built with Flutter — Designed for business scalability.

> "Your store, in your pocket — manage it from anywhere." 🧵📱

