-- ============================================================
-- 后台管理员建表脚本（库：user_db）
-- 账号：admin / admin123 、demo@test.com / demo123
-- 密码存储：MD5(明文 + '@vue-login')，与前台用户登录一致
-- 幂等：DROP IF EXISTS + 重建 + 灌数据
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
