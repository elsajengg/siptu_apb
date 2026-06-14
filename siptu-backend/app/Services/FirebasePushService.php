<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class FirebasePushService
{
    /**
     * @return array{attempted: int, successful: int, failed: int}
     */
    public function send(array $tokens, string $title, string $body, array $data = []): array
    {
        $tokens = array_values(array_unique(array_filter($tokens)));

        if ($tokens === []) {
            return ['attempted' => 0, 'successful' => 0, 'failed' => 0];
        }

        try {
            $message = CloudMessage::new()
                ->withNotification(Notification::create($title, $body))
                ->withData(
                    collect($data)
                        ->map(fn ($value) => is_scalar($value) ? (string) $value : json_encode($value))
                        ->all()
                );

            $report = app(Messaging::class)->sendMulticast($message, $tokens);

            return [
                'attempted' => count($tokens),
                'successful' => $report->successes()->count(),
                'failed' => $report->failures()->count(),
            ];
        } catch (\Throwable $exception) {
            // Push failure must not roll back report/task data.
            Log::warning('Firebase push notification failed.', [
                'message' => $exception->getMessage(),
            ]);

            return [
                'attempted' => count($tokens),
                'successful' => 0,
                'failed' => count($tokens),
            ];
        }
    }
}
