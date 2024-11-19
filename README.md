<div align="center">

# 🚗 CarVision

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-%23FF6F00.svg?style=flat&logo=TensorFlow&logoColor=white)](https://tensorflow.org)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat&logo=nodedotjs&logoColor=white)](https://nodejs.org)

**Real-time car recognition and price prediction at your fingertips**

[Features](#features) • [Technology Stack](#technology-stack) • [Installation](#installation) • [Usage](#usage) • [Contributing](#contributing)

![Car Recognition Demo](https://via.placeholder.com/800x400?text=CarVision+Demo)

</div>

## 📋 Overview

CarVision is an innovative mobile application that brings instant car recognition and price prediction to your smartphone. Using advanced AI technology, it can identify car models and estimate their market value in under 2 seconds, making it an invaluable tool for car enthusiasts, buyers, and dealers.

### Key Metrics
- 🎯 **70% Test Accuracy**
- 🚙 **899 Supported Car Models**
- ⚡ **<2s Recognition Speed**
- 📊 **1.45M Training Images**

## ✨ Features

### 🔍 Instant Recognition
Upload or capture car images for immediate classification and valuation, powered by our sophisticated AI model.

### 💰 Smart Price Prediction
Get real-time market value estimates based on historical data and current market trends.

### 📱 User-Friendly Interface
Intuitive Flutter-based mobile app designed for seamless user experience across both iOS and Android platforms.

### 🎯 High Accuracy
Leverages the DVM-CAR 2.0 dataset with 1.45 million images for reliable car identification across 899 models.

## 🛠️ Technology Stack

### AI/ML Infrastructure
- **TensorFlow**: Core framework for our deep learning model
- **Transfer Learning**: Optimized training process (40% faster)
- **Custom Data Pipeline**: Efficient preprocessing and augmentation

### Mobile Application
- **Flutter**: Cross-platform mobile development
- **Camera Integration**: Real-time image capture
- **Custom UI Components**: Responsive design

### Backend Services
- **Node.js**: RESTful API implementation
- **MongoDB**: Data persistence and management
- **Cloud Integration**: Scalable model deployment

## 📦 Installation

### Prerequisites
```bash
# Install Flutter
flutter doctor

# Install Node.js dependencies
cd backend
npm install

# Install Flutter dependencies
cd mobile_app
flutter pub get
```

### Configuration
1. Create a `.env` file in the backend directory:
```env
MONGODB_URI=your_mongodb_uri
API_KEY=your_api_key
PORT=3000
```

2. Update the Flutter app configuration in `lib/config/`:
```dart
class AppConfig {
  static const String apiUrl = 'your_api_url';
  static const String apiKey = 'your_api_key';
}
```

## 🚀 Usage

### Starting the Backend
```bash
cd backend
npm start
```

### Running the Mobile App
```bash
cd mobile_app
flutter run
```

## 📁 Project Structure
```
CarVision/
├── backend/               # Node.js server
│   ├── src/              # Source code
│   ├── tests/            # Unit tests
│   └── package.json      # Dependencies
├── mobile_app/           # Flutter application
│   ├── lib/             # Application code
│   ├── assets/          # Resources
│   └── pubspec.yaml     # Dependencies
├── ml/                   # Machine learning
│   ├── models/          # Trained models
│   ├── training/        # Training scripts
│   └── utils/           # Helper functions
└── README.md            # Documentation
```

## 🧪 AI Model Details

### Model Architecture
- **Base**: Modified EfficientNet
- **Training**: Transfer learning with custom layers
- **Optimization**: Custom data chunking pipeline

### Performance
- **Classification Accuracy**: 70% on test set
- **Inference Time**: <2 seconds
- **Model Size**: Optimized for mobile deployment

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- [DVM-CAR 2.0 Dataset](https://www.kaggle.com/datasets) for the comprehensive vehicle image database
- TensorFlow team for the excellent machine learning framework
- Flutter team for the robust mobile development platform

## 👤 Author

**Taha Khamessi**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230077B5.svg?style=flat&logo=linkedin&logoColor=white)](https://linkedin.com/in/taha-khamessi)
[![GitHub](https://img.shields.io/badge/GitHub-%23121011.svg?style=flat&logo=github&logoColor=white)](https://github.com/taha-khamessi)

---
<div align="center">
Made with ❤️ by the CarVision Team
</div>
