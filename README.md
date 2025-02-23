# **Survivor AI**
🚀 **Survivor AI** is a unique **offline mobile application** that provides **accurate diagnostic insights and actionable solutions** without requiring an **internet connection**. Our system leverages **advanced embeddings** to analyze user inputs, ask symptom-related questions, and verify potential illnesses—all while ensuring **maximum privacy and security**.

---

## **🛠️ Features**
- ✅ **100% Offline Functionality** – Works without an internet connection.
- ✅ **Optimized for Low-Resource Devices** – Efficient even on older hardware.
- ✅ **Smart Symptom Analysis** – Uses embeddings to understand symptoms.
- ✅ **Privacy-Focused** – No data is sent to external servers.

---

## **📌 Setup Instructions**

### **1️⃣ Install Backend Dependencies**
Run the following command to install necessary dependencies:
```bash
pip install -r requirements.txt
```

### **2️⃣ Configure Vector Database (Optional)**
Our project includes a **pre-built vector database**, but if you'd like to create your own:
- Modify the `database.py` script located in the `backend/` folder.
- Run the script to generate a **new vector database**.

### **3️⃣ Set Up Flutter Environment**
To ensure Flutter runs correctly:
1. **Install Java JDK 17** (required for Gradle).
2. Open `android/gradle.properties` and set the JDK path:
   ```properties
   org.gradle.java.home=/path/to/your/JDK
   ```
3. Ensure you are using **Gradle 8.2**.

### **4️⃣ Configure Android SDK Paths**
In `android/local.properties`, ensure these paths are correctly set for your system:
```properties
sdk.dir=/path/to/android/sdk
flutter.sdk=/path/to/flutter/sdk
```

---

## **🚀 Running the Project**

### **1️⃣ Start the Backend Server**
Run the following command in the backend directory:
```bash
python app.py
```
This starts the **FastAPI backend** using Uvicorn.

### **2️⃣ Run the Flutter App**
Navigate to the frontend (`miami/`) directory:
```bash
cd miami
flutter run
```
This launches the Flutter app on an emulator or physical device.
