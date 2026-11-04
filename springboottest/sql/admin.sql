-- ============================================================
-- 【已废弃】后台管理员建表脚本（库：user_db）
-- 后台登录已改为校验 user 表的 permission 字段（0=管理员），
-- 不再使用独立的 admin 表，本脚本仅作历史保留。
-- ============================================================
USE user_db;

SET NAMES utf8mb4;

DROP TABLE IF EXISTS admin;
CREATE TABLE admin (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    username    VARCHAR(100) NOT NULL COMMENT '登录账号（用户名或邮箱）',
    password    VARCHAR(100) NOT NULL COMMENT '密码（MD5+盐）',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '后台管理员';

-- admin123 → MD5('admin123@vue-login')
INSERT INTO admin (username, password) VALUES
('admin', '62d4764d70465f5fa559287d441f14c7');

-- demo123 → MD5('demo123@vue-login')
INSERT INTO admin (username, password) VALUES
('demo@test.com', '22f484c7616023e5057da619d4342c34');
