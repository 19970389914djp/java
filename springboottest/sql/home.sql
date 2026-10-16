-- ============================================================
-- 首页功能建表脚本（库：user_db，已存在则直接使用）
--   honor       生涯荣誉展示卡
--   moment      高光时刻（搜索的数据源）
--   hot_keyword 热门搜索词
-- 幂等：可重复执行（DROP IF EXISTS + 重建 + 灌数据）
-- ============================================================
USE user_db;

SET NAMES utf8mb4;

-- ---------- 生涯荣誉 ----------
DROP TABLE IF EXISTS honor;
CREATE TABLE honor (
    id         BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    label      VARCHAR(50)  NOT NULL COMMENT '荣誉名称（如：总冠军）',
    value      VARCHAR(50)  NOT NULL COMMENT '荣誉数值（如：4、40000+）',
    sort_order INT          NOT NULL DEFAULT 0 COMMENT '展示顺序，越小越靠前',
    PRIMARY KEY (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '生涯荣誉';

INSERT INTO honor (label, value, sort_order) VALUES
('总冠军',    '4',      1),
('总决赛 MVP', '4',      2),
('常规赛 MVP', '4',      3),
('生涯总得分', '40000+', 4);

-- ---------- 高光时刻 ----------
DROP TABLE IF EXISTS moment;
CREATE TABLE moment (
    id          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
    `year`      VARCHAR(10)   NOT NULL COMMENT '年份（展示用，如 2016、23）',
    title       VARCHAR(100)  NOT NULL COMMENT '标题',
    description VARCHAR(500)  NOT NULL COMMENT '描述',
    tags        VARCHAR(200)  NOT NULL DEFAULT '' COMMENT '标签，逗号分隔（如：骑士,总冠军,翻盘）',
    sort_order  INT           NOT NULL DEFAULT 0 COMMENT '展示顺序，越小越靠前',
    create_time DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    KEY idx_year (year)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '高光时刻';

INSERT INTO moment (`year`, title, description, tags, sort_order) VALUES
('2003', '天选之子降临',
 '阿克伦之子以状元身份加盟克利夫兰骑士，The Chosen One 的故事从此开始。',
 '骑士,选秀,状元', 1),
('2012', '首冠加冕',
 '迈阿密之夜，击败雷霆捧起生涯第一座总冠军奖杯，王者之路正式启程。',
 '热火,总冠军', 2),
('2013', '卫冕之战',
 '总决赛对阵马刺，37 分神奇一波流续命，最终卫冕成功并再夺 FMVP。',
 '热火,总冠军,卫冕', 3),
('2016', '1-3 史诗翻盘',
 '总决赛 1-3 落后 73 胜勇士，连扳三场为克利夫兰带来 52 年首座冠军。',
 '骑士,总冠军,翻盘', 4),
('2016', 'The Block',
 '抢七最后时刻追身大帽伊戈达拉，史诗级防守载入史册。',
 '骑士,名场面,防守', 5),
('2020', '紫金复辟',
 '率领湖人夺得队史第 17 冠，为科比而战，紫金王朝再度闪耀。',
 '湖人,总冠军,曼巴', 6),
('2024', '40000 分里程碑',
 '成为 NBA 历史首位生涯总得分突破 40000 分的球员，前无古人。',
 '湖人,里程碑,得分王', 7),
('23',   '粉笔仪式',
 '赛前撒镁粉的标志性仪式，从克利夫兰到洛杉矶，仪式感拉满。',
 '仪式,23号', 8);

-- ---------- 热门搜索词 ----------
DROP TABLE IF EXISTS hot_keyword;
CREATE TABLE hot_keyword (
    id         BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    keyword    VARCHAR(50)  NOT NULL COMMENT '搜索词',
    sort_order INT          NOT NULL DEFAULT 0 COMMENT '展示顺序，越小越靠前',
    PRIMARY KEY (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '热门搜索词';

INSERT INTO hot_keyword (keyword, sort_order) VALUES
('总冠军',   1),
('2016',    2),
('湖人',     3),
('40000分', 4),
('天选之子', 5);
