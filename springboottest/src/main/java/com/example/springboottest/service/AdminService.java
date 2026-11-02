package com.example.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.springboottest.common.Result;
import com.example.springboottest.entity.Admin;

import java.util.Map;

public interface AdminService extends IService<Admin> {

    /** 后台登录（仅账密，无验证码），成功返回内存 token */
    Result<Map<String, Object>> login(String username, String password);

    /** 校验请求头中的 token 是否有效 */
    boolean checkToken(String token);

    /** 注销 token */
    void logout(String token);
}
