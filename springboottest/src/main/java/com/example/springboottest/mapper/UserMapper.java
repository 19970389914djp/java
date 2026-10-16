package com.example.springboottest.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.springboottest.entity.User;

/**
 * 用户表 Mapper，继承 BaseMapper 即拥有常用 CRUD 方法
 */
public interface UserMapper extends BaseMapper<User> {
}
