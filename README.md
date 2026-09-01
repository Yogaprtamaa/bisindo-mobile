# BISINDO Mobile — Realtime Sign Language Detector

> Penerjemah Bahasa Isyarat Indonesia (BISINDO) berbasis Flutter & Computer Vision. Menerjemahkan isyarat huruf dan kata menjadi teks secara realtime untuk menjembatani komunikasi teman Tuli.

<p>
  <img src="https://img.shields.io/badge/Flutter-3.9-%2302569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.9-%230175C2?logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey" alt="Platform"/>
  <img src="https://img.shields.io/badge/Model-YOLOv8%20TFLite-00 chips?color=004D40" alt="Model"/>
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License"/>
</p>

---

## Daftar Isi
- [Tentang Proyek](#tentang-proyek)
- [Fitur Utama](#fitur-utama)
- [Arsitektur & Model](#arsitektur--model)
- [Tech Stack](#tech-stack)
- [Struktur Proyek](#struktur-proyek)
- [Prasyarat](#prasyarat)
- [Instalasi & Menjalankan](#instalasi--menjalankan)
- [Cara Penggunaan](#cara-penggunaan)
- [Konfigurasi Developer](#konfigurasi-developer)
- [Status Pengembangan](#status-pengembangan)
- [Roadmap](#roadmap)
- [Kontribusi](#kontribusi)
- [Lisensi](#lisensi)

---

## Tentang Proyek

**BISINDO Mobile** adalah aplikasi Flutter untuk deteksi BISINDO secara realtime. Aplikasi menampilkan bounding box + label + confidence score langsung di atas camera preview dan menerjemahkannya menjadi teks.

Fokus utama proyek: **akurasi UX di lapangan** — mengatasi *model bias* (mis. huruf `L` sering terprediksi sebagai kata `KAKAK`/`LAKI-LAKI`) melalui strategi pemisahan mode yang ketat.

> Saat ini repository berada pada **Slicing / Mock Mode** (UI tanpa dependensi native). Integrasi kamera + TFLite (`camera`, `flutter_vision` / `tflite_flutter`) diaktifkan kembali pada tahap integrasi model.

---

## Fitur Utama

| Fitur | Deskripsi |
|---|---|
| **Realtime Detection** | Stream kamera → inferensi YOLOv8 → overlay hasil di < 100ms |
| **Strict Switch Mode** | Pemisahan mutlak deteksi **Abjad** vs **Kata** via toggle (ABC / Chat Bubble) |
| **Confidence Smoothing** | Rata-rata 5 frame terakhir untuk stabilitas prediksi |
| **Anti-Flicker & Ghosting Guard** | Smoothing bounding box + memory wipe saat ganti mode |
| **Flashlight Toggle** | Bantuan pencahayaan di kondisi low-light |
| **Onboarding** | 3 halaman intro + navigasi ke detector |
| **Kamus Visual** | Dialog zoomable `assets/abjad.jfif` sebagai panduan isyarat |
| **Debug Panel** | Slider threshold & inspector scenario (mode slicing) |

---

## Arsitektur & Model

| Komponen | Detail |
|---|---|
| **Model** | YOLOv8 (Quantized Float16) |
| **Format** | `.tflite` — `assets/best_float32_V2.tflite`, `assets/model_abjad.tflite`, `assets/model_kata.tflite` |
| **Input** | 640 × 640 |
| **Kelas** | Huruf `A–Z` + kata umum (`Aku`, `Kamu`, `Makan`, `Minum`, dll.) |
| **Threshold Default** | `0.15` di production (agar huruf sulit seperti `C` tetap masuk pipeline), `0.40` di slicing mock |
| **Label** | `assets/labels*.txt` — dibersihkan dengan `.trim()` & regex untuk menangani `\r` / whitespace |

### Strategi Deteksi

**Strict Switch Mode (aktif)** — satu mode aktif dalam satu waktu:

- **Mode Abjad:** buang semua prediksi dengan `label.length > 1` (kata)
- **Mode Kata:** buang semua prediksi dengan `label.length == 1` (huruf)

Hasil: tidak ada lagi kasus `C` kalah skor dari kata lain, atau `L` terdeteksi sebagai `KAKAK`.

<details>
<summary>Heuristic "Nerf & Buff" (deprecated)</summary>

Memanipulasi confidence score secara matematis (penalti untuk kata, bonus untuk huruf). Dihentikan karena tidak konsisten di low-light.

</details>

---

## Tech Stack

| Layer | Teknologi |
|---|---|
| **Framework** | Flutter 3.9 (Material 3, `ColorScheme.fromSeed` — Teal `0xFF004D40`) |
| **Bahasa** | Dart 3.9 |
| **Vision (production)** | `flutter_vision` / `tflite_flutter`, `camera` |
| **State** | StatefulWidget + `Timer.periodic` (mock), siap migrasi ke Riverpod/Bloc |
| **Lint** | `flutter_lints` 5.0 |

---

## Struktur Proyek

```
lib/
├── main.dart                 # Entry point, ThemeData & orientation
├── intro_page.dart           # Onboarding 3 halaman (PageView + indicator)
├── detection_page.dart       # Slicing detector — mock preview, boxes, status
└── data/
    └── mock_bisindo_data.dart # Scenario mock Abjad & Kata

assets/
├── best_float32_V2.tflite
├── model_abjad.tflite
├── model_kata.tflite
├── labels.txt / labels_abjad.txt / labels_kata.txt
└── abjad.jfif                # Poster abjad BISINDO

android/ ios/ macos/ linux/ windows/ web/
```

---

## Prasyarat

- Flutter SDK `^3.9.2` — `flutter doctor`
- Dart SDK `^3.9.2`
- Device fisik Android/iOS untuk uji kamera (emulator tidak optimal untuk camera stream)
- Git

---

## Instalasi & Menjalankan

```bash
# 1. Clone
git clone https://github.com/Yogaprtamaa/bisindo-mobile.git
cd bisindo-mobile

# 2. Dependensi
flutter pub get

# 3. Jalankan (device fisik / emulator)
flutter run

# 4. Build release
flutter build apk --release        # Android
flutter build ios --release        # iOS (di macOS dengan Xcode)
flutter build web --release        # Web (preview terbatas tanpa kamera)
```

> **Catatan asset:** Pastikan file di `assets/` terdaftar di `pubspec.yaml` pada `flutter.assets`. Model `.tflite` >10 MB — GitHub membatasi 100 MB/file; pertimbangkan Git LFS untuk model produksi.

---

## Cara Penggunaan

1. **Onboarding** — swipe atau tekan `Next` / `Skip` untuk masuk ke detector.
2. **Mulai deteksi** — tekan tombol **Play** (FAB tengah). Mock preview akan mensimulasikan pergantian scenario tiap 1.8s.
3. **Ganti mode** — ikon `ABC` (Abjad) ↔ `Chat Bubble` (Kata) di AppBar. Status `MODE: ABJAD/KATA` muncul di bawah preview.
4. **Navigasi scenario** — saat deteksi aktif, gunakan `‹` / `›` untuk prev/next scenario.
5. **Kamus** — ikon buku untuk membuka poster `abjad.jfif` (pinch-to-zoom).
6. **Debug** — ikon bug untuk membuka panel threshold (`0.10–0.90`).

---

## Konfigurasi Developer

### Threshold

```dart
// lib/detection_page.dart
double displayConfThreshold = 0.40; // slicing
// production: 0.15 agar recall tinggi, filter lanjutan via Strict Switch
```

### Label sanitization

```dart
final label = rawLabel.trim().replaceAll(RegExp(r'[\r\n]'), '');
final isWord = label.length > 1;
```

### Mengaktifkan kembali kamera + TFLite

1. Tambahkan ke `pubspec.yaml`:
   ```yaml
   dependencies:
     camera: ^0.10.6
     tflite_flutter: ^0.10.4
     flutter_vision: ^1.1.4
   ```
2. Ganti `_buildMockPreview` dengan `CameraPreview` + `FlutterVision.yoloOnFrame`.
3. Gunakan `Strict Switch` filter yang sudah ada di `_filterByThreshold` / logika label-length.

---

## Status Pengembangan

| Tahap | Status |
|---|---|
| Slicing UI (Intro + Detector Mock) | ✅ Selesai |
| Integrasi Kamera & TFLite | 🔄 Berikutnya |
| Evaluasi model & tuning threshold | ⏳ Terjadwal |
| Build & distribusi (APK/TestFlight) | ⏳ Terjadwal |

---

## Roadmap

- [ ] Integrasi `camera` + `tflite_flutter` dengan isolate inference
- [ ] Benchmark FPS & akurasi per-device (low-end Android)
- [ ] Mode kalimat (buffer + auto-spacing)
- [ ] Text-to-Speech untuk hasil terjemahan
- [ ] Riwayat terjemahan & ekspor teks

---

## Kontribusi

Kontribusi sangat diterima. Silakan:

1. Fork repository
2. Buat branch `feat/nama-fitur` atau `fix/nama-bug`
3. Commit dengan pesan konvensional (`feat:`, `fix:`, `docs:`)
4. Buka Pull Request dengan deskripsi jelas + screenshot jika mengubah UI

Pastikan `flutter analyze` & `flutter test` lolos sebelum PR.

---

## Lisensi

Didistribusikan di bawah lisensi **MIT**. Lihat `LICENSE` untuk detail.

---

<p align="center">
  Dibuat untuk aksesibilitas komunikasi — dengan ☕, Flutter, dan YOLOv8.<br/>
  <sub>Maintainer: <a href="https://github.com/Yogaprtamaa">Yogaprtamaa</a> • Issues & diskusi via GitHub Issues</sub>
</p>
