-- ============================================================
-- 升级脚本：为已有 user_db 增加 permission 字段（幂等，可重复执行）
-- 权限：1=默认用户（注册用户默认值），0=管理员
-- 后台登录改为校验 user 表，仅 permission=0 可登录后台
-- ============================================================
USE user_db;

-- 新增 permission 字段（已存在则跳过）
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'user_db' AND TABLE_NAME = 'user' AND COLUMN_NAME = 'permission');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `user` ADD COLUMN `permission` TINYINT NOT NULL DEFAULT 1 COMMENT ''权限：1=默认用户，0=管理员'' AFTER `nickname`',
    'SELECT ''permission 列已存在''');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 密码字段注释改为明文存储
ALTER TABLE `user` MODIFY COLUMN `password` VARCHAR(100) NOT NULL COMMENT '密码（明文存储）';

-- 内置管理员账号（已存在则跳过）
INSERT INTO `user` (`email`, `password`, `nickname`, `permission`)
SELECT 'admin@test.com', 'admin123', '管理员', 0
WHERE NOT EXISTS (SELECT 1 FROM `user` WHERE `email` = 'admin@test.com');
