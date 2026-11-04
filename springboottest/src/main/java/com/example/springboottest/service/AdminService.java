package com.example.springboottest.service;

import com.example.springboottest.common.Result;

import java.util.Map;

/**
 * 后台管理服务
 * 登录校验 user 表的 permission 字段（0=管理员），不再依赖独立的 admin 表
 */
public interface AdminService {

    /** 后台登录（仅账密，无验证码），仅 permission=0 的账号可登录，成功返回内存 token */
    Result<Map<String, Object>> login(String username, String password);

    /** 校验请求头中的 token 是否有效 */
    boolean checkToken(String token);

    /** 注销 token */
    void logout(String token);
}
