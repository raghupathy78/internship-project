<?php
$redisClass = 'Redis';

if (class_exists($redisClass)) {
	$redis = new $redisClass();
	$redis->connect('127.0.0.1', 6379);
} else {
	/**
	 * Minimal file-backed cache so auth keeps working without the Redis extension.
	 */
	class FileTokenStore
	{
		private string $file;

		public function __construct(string $file)
		{
			$dir = dirname($file);
			if (!is_dir($dir)) {
				mkdir($dir, 0777, true);
			}
			if (!file_exists($file)) {
				file_put_contents($file, json_encode([]), LOCK_EX);
			}
			$this->file = $file;
		}

		public function setex(string $key, int $ttl, string $value): void
		{
			$data = $this->read();
			$data[$key] = [
				'value' => $value,
				'expires' => time() + $ttl,
			];
			$this->write($data);
		}

		public function get(string $key)
		{
			$data = $this->read();
			if (!isset($data[$key])) {
				return false;
			}
			if ($data[$key]['expires'] < time()) {
				unset($data[$key]);
				$this->write($data);
				return false;
			}
			return $data[$key]['value'];
		}

		private function read(): array
		{
			$content = file_get_contents($this->file);
			return $content ? (json_decode($content, true) ?: []) : [];
		}

		private function write(array $data): void
		{
			file_put_contents($this->file, json_encode($data), LOCK_EX);
		}
	}

	$redis = new FileTokenStore(__DIR__ . '/../storage/session_cache.json');
}
