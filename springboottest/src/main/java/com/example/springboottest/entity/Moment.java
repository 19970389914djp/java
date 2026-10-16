package com.example.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

/**
 * 高光时刻表（首页展示 + 搜索数据源）
 */
@TableName("moment")
public class Moment {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 年份（展示用，如 2016、23） */
    private String year;

    /** 标题 */
    private String title;

    /** 描述 */
    private String description;

    /** 标签，逗号分隔（如：骑士,总冠军,翻盘） */
    private String tags;

    /** 展示顺序，越小越靠前 */
    private Integer sortOrder;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getYear() {
        return year;
    }

    public void setYear(String year) {
        this.year = year;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getTags() {
        return tags;
    }

    public void setTags(String tags) {
        this.tags = tags;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }
}
