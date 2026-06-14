# SIPTU Backend

Backend memakai Laravel Sanctum, MySQL, penyimpanan file Laravel, dan Firebase
Cloud Messaging (FCM).

## Struktur database

- `users`: satu sumber identitas untuk admin, staff, dan user melalui `role`.
- `rooms`: gedung dan nama ruang.
- `facilities`: fasilitas yang berada di sebuah ruang.
- `reports`: laporan kerusakan yang dibuat user.
- `report_photos`: satu laporan dapat memiliki maksimal lima foto.
- `tasks`: penugasan satu report kepada satu staff oleh admin.
- `task_updates`: histori status dan catatan pekerjaan staff.
- `task_update_photos`: dokumentasi setiap update pekerjaan.
- `device_tokens`: token FCM milik perangkat user.
- `user_notifications`: inbox notifikasi yang tetap tersedia walaupun push gagal.

Tidak ada tabel `admin` dan `staff` terpisah karena nama, email, dan password
akan terduplikasi. Data khusus pegawai disimpan pada `users.nip`.

## Status

Report:

- `pending`: menunggu verifikasi.
- `assigned`: sudah ditugaskan.
- `on_progress`: sedang dikerjakan atau terkendala.
- `resolved`: selesai.
- `rejected`: ditolak admin.

Task:

- `assigned`
- `on_progress`
- `blocked`
- `resolved`

## Endpoint

Semua endpoint selain login memakai:

```text
Authorization: Bearer <sanctum-token>
Accept: application/json
```

| Method | Endpoint | Role | Fungsi |
|---|---|---|---|
| POST | `/api/login` | Publik | Login dan membuat token Sanctum |
| POST | `/api/logout` | Semua | Menghapus token aktif |
| GET | `/api/facilities` | Semua | Referensi fasilitas untuk form report |
| GET | `/api/reports` | Semua | Daftar report sesuai hak akses |
| POST | `/api/reports` | User | Membuat report multipart dengan `photos[]` |
| GET | `/api/reports/{report}` | Terkait | Detail report, task, dan histori update |
| POST | `/api/reports/{report}/assign` | Admin | Menugaskan report ke staff |
| POST | `/api/reports/{report}/reject` | Admin | Menolak report |
| POST | `/api/reports/{report}/feedback` | Pelapor | Rating setelah report selesai |
| GET | `/api/tasks` | Admin/Staff | Daftar task |
| POST | `/api/tasks/{task}/updates` | Staff terkait | Upload status, catatan, dan `photos[]` |
| POST | `/api/devices` | Semua | Daftarkan FCM token perangkat |
| DELETE | `/api/devices` | Semua | Hapus FCM token perangkat |
| GET | `/api/notifications` | Semua | Inbox notifikasi |
| POST | `/api/notifications/test` | Semua (local) | Kirim push uji ke akun aktif |
| PATCH | `/api/notifications/{id}/read` | Pemilik | Tandai notifikasi dibaca |
| PATCH | `/api/notifications/read-all` | Semua | Tandai seluruh notifikasi dibaca |

Update task dengan status `resolved` wajib memiliki minimal satu foto bukti.

## Firebase

1. Unduh service-account JSON dari Firebase Console.
2. Simpan sebagai `storage/app/firebase-service-account.json`.
3. Atur `FIREBASE_CREDENTIALS` di `.env`.
4. Flutter mengambil FCM token melalui package `firebase_messaging`, lalu
   mengirimkannya ke `POST /api/devices` setelah login.

Backend menyimpan notifikasi ke MySQL terlebih dahulu, kemudian mengirim push
FCM. Jika Firebase belum dikonfigurasi atau sedang gagal, data report/task tetap
tersimpan dan error push dicatat di log.

Endpoint test hanya aktif saat `APP_ENV=local` atau `testing`. Login dari Flutter
terlebih dahulu agar FCM token tersimpan, lalu panggil endpoint tersebut dengan
Bearer token. Respons menampilkan jumlah push berhasil dan gagal.

Untuk Android Emulator, jalankan Flutter dengan alamat host emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

Untuk perangkat fisik, ganti `10.0.2.2` dengan IP LAN komputer yang menjalankan
Laravel dan jalankan server menggunakan `php artisan serve --host=0.0.0.0`.

## Menjalankan

```bash
composer install
php artisan migrate
php artisan storage:link
php artisan db:seed
php artisan test
```

Akun seeder:

| Role | Email | Password |
|---|---|---|
| Admin | `admin@siptu.test` | `admin123` |
| Staff | `staff@siptu.test` | `staff123` |
| User | `elsa@siptu.test` | `user123` |
| User | `charlene@siptu.test` | `user123` |
