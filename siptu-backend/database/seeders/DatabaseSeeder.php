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

        $roomA = Room::updateOrCreate(
            ['building_name' => 'Gedung SBS', 'room_name' => 'Lab CyberSecurity'],
        );
        $roomB = Room::updateOrCreate(
            ['building_name' => 'Gedung Utama', 'room_name' => 'Ruang Sidang Utama'],
        );
        $roomC = Room::updateOrCreate(
            ['building_name' => 'Gedung SBS', 'room_name' => 'Lab Programming'],
        );
        $roomD = Room::updateOrCreate(
            ['building_name' => 'Gedung Utama', 'room_name' => 'Koridor Timur Lantai 3'],
        );

        $airConditioner = Facility::updateOrCreate(
            ['code' => 'AC-A-204'],
            [
                'room_id' => $roomA->id,
                'name' => 'AC Ruang 204',
                'category' => 'Kenyamanan Ruangan',
                'status' => 'active',
            ],
        );
        $lamp = Facility::updateOrCreate(
            ['code' => 'LMP-B-3E'],
            [
                'room_id' => $roomB->id,
                'name' => 'Lampu Koridor Timur',
                'category' => 'Penerangan',
                'status' => 'active',
            ],
        );
        $lamp = Facility::updateOrCreate(
            ['code' => 'LMP-C-301'],
            [
                'room_id' => $roomC->id,
                'name' => 'Lampu Ruang 301',
                'category' => 'Penerangan',
                'status' => 'active',
            ],
        );
        $lamp = Facility::updateOrCreate(
            ['code' => 'LMP-D-3E'],
            [
                'room_id' => $roomD->id,
                'name' => 'Lampu Koridor Timur Lantai 3',
                'category' => 'Penerangan',
                'status' => 'active',
            ],
        );

        $assignedReport = Report::updateOrCreate(
            ['ticket_number' => 'TIK-20260614-001'],
            [
                'user_id' => $elsa->id,
                'facility_id' => $airConditioner->id,
                'title' => 'AC Ruang 204 Tidak Dingin',
                'description' => 'AC hanya mengeluarkan angin dan ruangan terasa panas.',
                'location' => 'Gedung A, Ruang 204',
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
                'facility_id' => $lamp->id,
                'title' => 'Lampu Koridor Gedung B Mati',
                'description' => 'Koridor lantai tiga gelap pada malam hari.',
                'location' => 'Gedung B, Lantai 3, Koridor Timur',
                'category' => 'Penerangan',
                'status' => 'pending',
            ],
        );
    }
}
