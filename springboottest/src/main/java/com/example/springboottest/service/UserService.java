package com.example.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.springboottest.common.Result;
import com.example.springboottest.entity.User;

import java.util.Map;

public interface UserService extends IService<User> {

    /** 发送验证码（本地开发：生成后打印到控制台并在响应中返回） */
    Result<Map<String, String>> sendCode(String target);

    /** 邮箱注册 */
    Result<Void> register(String email, String password, String code);

    /** 登录（账号 = 邮箱） */
    Result<Map<String, Object>> login(String account, String password, String code);
}
