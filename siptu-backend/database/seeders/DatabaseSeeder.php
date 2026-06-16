<?php

namespace Database\Seeders;

use App\Models\Facility;
use App\Models\Report;
use App\Models\Room;
use App\Models\Task;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $admin = User::updateOrCreate(
            ['email' => 'admin@siptu.test'],
            [
                'name' => 'Bagus Faaza',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
                'nip' => 'ADM-001',
            ],
        );

        $staff = User::updateOrCreate(
            ['email' => 'staff@siptu.test'],
            [
                'name' => 'Muhammad Iqbal',
                'password' => Hash::make('staff123'),
                'role' => 'staff',
                'nip' => '198901012020121001',
            ],
        );

        $elsa = User::updateOrCreate(
            ['email' => 'elsa@siptu.test'],
            [
                'name' => 'Elsa Ajeng',
                'password' => Hash::make('user123'),
                'role' => 'user',
                'nip' => null,
            ],
        );

        User::updateOrCreate(
            ['email' => 'charlene@siptu.test'],
            [
                'name' => 'Charlene Ridsianeva',
                'password' => Hash::make('user123'),
                'role' => 'user',
                'nip' => null,
            ],
        );

        $rooms = [];
        foreach ([
            ['key' => 'sbs_lab_cyber', 'building' => 'Gedung SBS', 'room' => 'Lab CyberSecurity'],
            ['key' => 'sbs_lab_programming', 'building' => 'Gedung SBS', 'room' => 'Lab Programming'],
            ['key' => 'sbs_kelas_201', 'building' => 'Gedung SBS', 'room' => 'Ruang Kelas 201'],
            ['key' => 'sbs_kamar_mandi_1', 'building' => 'Gedung SBS', 'room' => 'Kamar Mandi Lantai 1'],
            ['key' => 'sbs_kamar_mandi_2', 'building' => 'Gedung SBS', 'room' => 'Kamar Mandi Lantai 2'],
            ['key' => 'utama_sidang', 'building' => 'Gedung Utama', 'room' => 'Ruang Sidang Utama'],
            ['key' => 'utama_koridor_3', 'building' => 'Gedung Utama', 'room' => 'Koridor Timur Lantai 3'],
            ['key' => 'utama_kamar_mandi_3', 'building' => 'Gedung Utama', 'room' => 'Kamar Mandi Lantai 3'],
        ] as $roomSeed) {
            $rooms[$roomSeed['key']] = Room::updateOrCreate([
                'building_name' => $roomSeed['building'],
                'room_name' => $roomSeed['room'],
            ]);
        }

        $facilities = [];
        foreach ([
            ['key' => 'ac_lab_cyber', 'room' => 'sbs_lab_cyber', 'code' => 'SBS-CYB-AC', 'name' => 'AC Lab CyberSecurity', 'category' => 'Kenyamanan Ruangan'],
            ['key' => 'pc_lab_cyber', 'room' => 'sbs_lab_cyber', 'code' => 'SBS-CYB-PC', 'name' => 'Komputer Lab CyberSecurity', 'category' => 'Perangkat Lab'],
            ['key' => 'ac_lab_programming', 'room' => 'sbs_lab_programming', 'code' => 'SBS-PRG-AC', 'name' => 'AC Lab Programming', 'category' => 'Kenyamanan Ruangan'],
            ['key' => 'proyektor_lab_programming', 'room' => 'sbs_lab_programming', 'code' => 'SBS-PRG-PRJ', 'name' => 'Proyektor Lab Programming', 'category' => 'Perangkat Pembelajaran'],
            ['key' => 'kursi_kelas_201', 'room' => 'sbs_kelas_201', 'code' => 'SBS-201-KRS', 'name' => 'Meja dan Kursi Ruang 201', 'category' => 'Inventaris Kelas'],
            ['key' => 'proyektor_kelas_201', 'room' => 'sbs_kelas_201', 'code' => 'SBS-201-PRJ', 'name' => 'Proyektor Ruang 201', 'category' => 'Perangkat Pembelajaran'],
            ['key' => 'toilet_sbs_1', 'room' => 'sbs_kamar_mandi_1', 'code' => 'SBS-WC-1', 'name' => 'Kloset dan Wastafel Lantai 1', 'category' => 'Sanitasi'],
            ['key' => 'toilet_sbs_2', 'room' => 'sbs_kamar_mandi_2', 'code' => 'SBS-WC-2', 'name' => 'Kloset dan Wastafel Lantai 2', 'category' => 'Sanitasi'],
            ['key' => 'audio_sidang', 'room' => 'utama_sidang', 'code' => 'UTM-SDG-AUD', 'name' => 'Audio Ruang Sidang', 'category' => 'Audio Visual'],
            ['key' => 'lampu_sidang', 'room' => 'utama_sidang', 'code' => 'UTM-SDG-LMP', 'name' => 'Lampu Ruang Sidang', 'category' => 'Penerangan'],
            ['key' => 'lampu_koridor_3', 'room' => 'utama_koridor_3', 'code' => 'UTM-KOR-3-LMP', 'name' => 'Lampu Koridor Timur Lantai 3', 'category' => 'Penerangan'],
            ['key' => 'toilet_utama_3', 'room' => 'utama_kamar_mandi_3', 'code' => 'UTM-WC-3', 'name' => 'Kloset dan Wastafel Lantai 3', 'category' => 'Sanitasi'],
        ] as $facilitySeed) {
            $facilities[$facilitySeed['key']] = Facility::updateOrCreate(
                ['code' => $facilitySeed['code']],
                [
                    'room_id' => $rooms[$facilitySeed['room']]->id,
                    'name' => $facilitySeed['name'],
                    'category' => $facilitySeed['category'],
                    'status' => 'active',
                ],
            );
        }

        $assignedReport = Report::updateOrCreate(
            ['ticket_number' => 'TIK-20260614-001'],
            [
                'user_id' => $elsa->id,
                'facility_id' => $facilities['ac_lab_cyber']->id,
                'title' => 'AC Ruang 204 Tidak Dingin',
                'description' => 'AC hanya mengeluarkan angin dan ruangan terasa panas.',
                'location' => 'Gedung SBS, Lab CyberSecurity',
                'room_detail' => 'Area depan dekat meja dosen',
                'category' => 'Kenyamanan Ruangan',
                'status' => 'on_progress',
            ],
        );

        $task = Task::updateOrCreate(
            ['task_number' => 'TGS-20260614-001'],
            [
                'report_id' => $assignedReport->id,
                'assigned_by' => $admin->id,
                'staff_id' => $staff->id,
                'admin_notes' => 'Periksa refrigeran dan unit outdoor.',
                'staff_notes' => 'Refrigeran perlu diisi ulang.',
                'status' => 'on_progress',
                'deadline_at' => now()->addDays(2),
                'started_at' => now()->subHour(),
            ],
        );

        $task->updates()->updateOrCreate(
            ['created_by' => $staff->id, 'status' => 'on_progress'],
            ['notes' => 'Pemeriksaan awal selesai, refrigeran perlu diisi ulang.'],
        );

        Report::updateOrCreate(
            ['ticket_number' => 'TIK-20260614-002'],
            [
                'user_id' => $elsa->id,
                'facility_id' => $facilities['lampu_koridor_3']->id,
                'title' => 'Lampu Koridor Gedung B Mati',
                'description' => 'Koridor lantai tiga gelap pada malam hari.',
                'location' => 'Gedung Utama, Koridor Timur Lantai 3',
                'room_detail' => 'Dekat tangga sisi timur',
                'category' => 'Penerangan',
                'status' => 'pending',
            ],
        );
    }
}
