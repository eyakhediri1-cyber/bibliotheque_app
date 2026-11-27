# 📚 LibraryFlow

**LibraryFlow** est une application mobile et web de gestion de bibliothèque développée avec **Flutter et Dart**. Elle permet de gérer un catalogue de livres et d'écrivains, de rechercher des ouvrages, de consulter leurs informations, de gérer ses favoris et de découvrir de nouveaux livres grâce à l'API Google Books.

L'objectif du projet est de proposer une interface simple et intuitive pour organiser une bibliothèque et faciliter l'accès aux informations des ouvrages.

## ✨ Fonctionnalités

### 🏠 Tableau de bord
- Accès rapide aux différentes fonctionnalités.
- Vue d'ensemble de la bibliothèque.
- Navigation entre les différentes sections.

### 📖 Gestion des livres
- Ajouter de nouveaux livres.
- Consulter les détails d'un livre.
- Modifier les informations d'un ouvrage.
- Supprimer un livre.
- Rechercher des livres dans le catalogue.
- Associer un livre à son écrivain.
- Gérer les couvertures des livres.

### ✍️ Gestion des écrivains
- Ajouter des écrivains.
- Consulter leurs informations.
- Modifier et supprimer des écrivains.
- Retrouver les livres associés à chaque écrivain.

### ❤️ Favoris
- Ajouter des livres aux favoris.
- Consulter la liste des livres favoris.

### 🔎 Découverte de livres
- Rechercher des ouvrages à travers Google Books.
- Consulter les informations des livres disponibles.
- Découvrir des ouvrages qui ne figurent pas encore dans le catalogue.
- Importer des livres dans la bibliothèque.

### 📊 Statistiques
- Consulter les statistiques de la bibliothèque.
- Obtenir une vue synthétique du catalogue.

## 🛠️ Technologies utilisées

| Technologie | Utilisation |
|---|---|
| Flutter | Développement de l'interface multiplateforme |
| Dart | Langage de programmation |
| SQLite | Stockage local des données |
| sqflite | Gestion de la base de données |
| SharedPreferences | Stockage de préférences locales |
| Google Books API | Recherche et découverte de livres |
| Material Design | Conception de l'interface utilisateur |
| Git / GitHub | Gestion de versions et hébergement du code |

## 🏗️ Architecture du projet

Le projet est organisé de manière à séparer les interfaces, les modèles de données et les services.

```text
lib/
│
├── main.dart
│
├── models/
│   ├── livre.dart
│   ├── ecrivain.dart
│   └── google_book.dart
│
├── pages/
│   ├── home_page.dart
│   ├── livres_page.dart
│   ├── ecrivains_page.dart
│   ├── statistiques_page.dart
│   ├── favoris_page.dart
│   ├── recherche_page.dart
│   └── decouvrir_livres_page.dart
│
├── services/
│   ├── sql_helper.dart
│   ├── google_books_service.dart
│   └── catalogue_initial_service.dart
│
├── widgets/
│   └── ...
│
└── theme/
    └── ...
```

*Cette arborescence présente les principaux éléments de l'application ; certains fichiers et dossiers peuvent varier selon la version du projet.*

## 🗄️ Base de données

LibraryFlow utilise une base de données SQLite pour conserver les informations localement.

Les principales entités sont :

**Livre**
- Identifiant
- Titre
- ISBN
- Date de publication
- Couverture
- Informations descriptives
- Identifiant de l'écrivain

**Écrivain**
- Identifiant
- Nom
- Informations relatives à l'écrivain

### Relation entre les entités

Un écrivain peut être associé à plusieurs livres. Chaque livre est associé à un écrivain à travers son identifiant (`ecrivainId`).

Les opérations CRUD (Create, Read, Update, Delete) permettent de gérer les données de la bibliothèque.

## 🚀 Installation et lancement

### 1. Prérequis

Avant de commencer, il faut disposer de :

- Flutter SDK
- Dart SDK
- Android Studio ou Visual Studio Code
- Google Chrome pour la version Web
- Un émulateur Android ou un appareil Android pour la version mobile

Vérifier l'installation de Flutter :

```bash
flutter doctor
```

### 2. Cloner le projet

```bash
git clone https://github.com/eyakhediri1-cyber/bibliotheque_app.git
```

### 3. Accéder au dossier

```bash
cd bibliotheque_app
```

### 4. Installer les dépendances

```bash
flutter pub get
```

### 5. Lancer l'application sur Chrome

```bash
flutter run -d chrome
```

### 6. Lancer l'application sur Android

Vérifier les appareils disponibles :

```bash
flutter devices
```

Puis lancer :

```bash
flutter run
```

Pour générer un APK de débogage :

```bash
flutter build apk --debug
```

Le fichier APK sera disponible dans :

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## 📱 Plateformes

LibraryFlow est conçu pour fonctionner sur :

- Android
- Web

## 🎯 Objectifs pédagogiques

Ce projet permet de mettre en pratique plusieurs concepts du développement d'applications :

- Développement multiplateforme avec Flutter.
- Programmation orientée objet avec Dart.
- Architecture d'une application.
- Gestion d'une base de données relationnelle.
- Opérations CRUD.
- Navigation entre plusieurs écrans.
- Intégration d'une API externe.
- Gestion des données locales.
- Utilisation de Git et GitHub.

## 👩‍💻 Auteur

**Eya Khediri**

Étudiante en troisième année de Licence Informatique.

GitHub : [@eyakhediri1-cyber](https://github.com/eyakhediri1-cyber)

---

*LibraryFlow — Organisez votre bibliothèque, découvrez vos prochaines lectures.*
