-- ============================================================
-- 用户登录/注册演示项目数据库脚本
-- 数据库：user_db    表：user
-- 使用方式：mysql -uroot -p123456 < user_db.sql
-- ============================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `user_db`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE `user_db`;

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键 ID',
  `email`       VARCHAR(100) NOT NULL                COMMENT '邮箱（注册账号）',
  `password`    VARCHAR(100) NOT NULL                COMMENT '密码（明文存储）',
  `nickname`    VARCHAR(50)  DEFAULT NULL            COMMENT '昵称',
  `permission`  TINYINT      NOT NULL DEFAULT 1      COMMENT '权限：1=默认用户，0=管理员',
  `create_time` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_email` (`email`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COMMENT = '用户表';

-- 内置管理员账号（仅新建库时插入）：admin@test.com / admin123
INSERT INTO `user` (`email`, `password`, `nickname`, `permission`)
SELECT 'admin@test.com', 'admin123', '管理员', 0
WHERE NOT EXISTS (SELECT 1 FROM `user` WHERE `email` = 'admin@test.com');
