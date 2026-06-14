<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Collection;

class UserNotifier
{
    public function __construct(private readonly FirebasePushService $firebase) {}

    /**
     * @return array{attempted: int, successful: int, failed: int}
     */
    public function send(User|Collection|array $recipients, string $type, string $title, string $message, array $data = []): array
    {
        $users = $recipients instanceof User
            ? collect([$recipients])
            : collect($recipients);

        $users = $users->filter()->unique('id')->values();

        foreach ($users as $user) {
            $user->userNotifications()->create([
                'type' => $type,
                'title' => $title,
                'message' => $message,
                'data' => $data,
            ]);
        }

        $tokens = $users
            ->flatMap(fn (User $user) => $user->deviceTokens()->pluck('token'))
            ->all();

        return $this->firebase->send($tokens, $title, $message, ['type' => $type, ...$data]);
    }
}
