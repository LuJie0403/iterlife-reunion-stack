-- 用户级会话归属与互踢基线
-- 创建日期：2026-04-26
-- 最后更新：2026-04-26
--
-- 目的：
--   1. 为 authenticate_session 增加 user_id 与 revoke_reason，支持用户级会话归属与用户级互踢；
--   2. 回填历史会话的 user_id。

SET @has_session_user_id := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'authenticate_session'
      AND COLUMN_NAME = 'user_id'
);
SET @sql := IF(
    @has_session_user_id = 0,
    'ALTER TABLE authenticate_session ADD COLUMN user_id VARCHAR(32) NULL COMMENT ''归属用户主键'' AFTER session_id',
    'SELECT ''authenticate_session.user_id already exists'' AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @has_session_revoke_reason := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'authenticate_session'
      AND COLUMN_NAME = 'revoke_reason'
);
SET @sql := IF(
    @has_session_revoke_reason = 0,
    'ALTER TABLE authenticate_session ADD COLUMN revoke_reason VARCHAR(64) NULL COMMENT ''会话失效原因'' AFTER revoked_at',
    'SELECT ''authenticate_session.revoke_reason already exists'' AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @has_idx_session_user_status := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'authenticate_session'
      AND INDEX_NAME = 'idx_authenticate_session_user_status'
);
SET @sql := IF(
    @has_idx_session_user_status = 0,
    'ALTER TABLE authenticate_session ADD KEY idx_authenticate_session_user_status (user_id, status)',
    'SELECT ''idx_authenticate_session_user_status already exists'' AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE authenticate_session s
JOIN user_account ua
    ON ua.account_id = s.account_id
SET
    s.user_id = ua.user_id
WHERE (s.user_id IS NULL OR TRIM(s.user_id) = '')
  AND ua.user_id IS NOT NULL
  AND TRIM(ua.user_id) <> '';
