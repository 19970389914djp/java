package com.example.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.springboottest.common.Result;
import com.example.springboottest.entity.Admin;
import com.example.springboottest.mapper.AdminMapper;
import com.example.springboottest.service.AdminService;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AdminServiceImpl extends ServiceImpl<AdminMapper, Admin> implements AdminService {

    /** 密码加盐值（与前台用户登录一致） */
    private static final String SALT = "@vue-login";

    /** 内存 token 存储：key = token，value = 登录账号（后端重启即失效） */
    private final Map<String, String> tokenStore = new ConcurrentHashMap<>();

    @Override
    public Result<Map<String, Object>> login(String username, String password) {
        if (username == null || username.trim().isEmpty()) {
            return Result.error("请输入账号");
        }
        if (password == null || password.trim().isEmpty()) {
            return Result.error("请输入密码");
        }
        username = username.trim();

        Admin admin = getOne(new LambdaQueryWrapper<Admin>().eq(Admin::getUsername, username));
        if (admin == null) {
            return Result.error("账号不存在");
        }
        if (!admin.getPassword().equals(encrypt(password))) {
            return Result.error("密码错误");
        }

        // 简易内存 token（学习项目，未接入 JWT，后端重启失效）
        String token = UUID.randomUUID().toString().replace("-", "");
        tokenStore.put(token, username);

        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("username", username);
        return Result.success("登录成功", data);
    }

    @Override
    public boolean checkToken(String token) {
        return token != null && !token.trim().isEmpty() && tokenStore.containsKey(token.trim());
    }

    @Override
    public void logout(String token) {
        if (token != null) {
            tokenStore.remove(token.trim());
        }
    }

    /** MD5 + 盐加密 */
    private String encrypt(String password) {
        return DigestUtils.md5DigestAsHex((password + SALT).getBytes(StandardCharsets.UTF_8));
    }
}
