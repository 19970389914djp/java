package com.example.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.springboottest.common.Result;
import com.example.springboottest.entity.User;
import com.example.springboottest.mapper.UserMapper;
import com.example.springboottest.service.AdminService;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 后台管理服务
 * 登录不再使用独立的 admin 表，而是校验 user 表：
 * 只有 permission = 0（管理员权限）的账号才能登录后台。
 */
@Service
public class AdminServiceImpl implements AdminService {

    /** 管理员权限值 */
    public static final int PERMISSION_ADMIN = 0;

    private final UserMapper userMapper;

    /** 内存 token 存储：key = token，value = 登录账号（后端重启即失效） */
    private final Map<String, String> tokenStore = new ConcurrentHashMap<>();

    public AdminServiceImpl(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    @Override
    public Result<Map<String, Object>> login(String username, String password) {
        if (username == null || username.trim().isEmpty()) {
            return Result.error("请输入账号");
        }
        if (password == null || password.trim().isEmpty()) {
            return Result.error("请输入密码");
        }
        username = username.trim();

        // 后台登录使用 user 表（邮箱 + 明文密码）
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getEmail, username));
        if (user == null) {
            return Result.error("账号不存在");
        }
        if (!user.getPassword().equals(password)) { // 明文比对
            return Result.error("密码错误");
        }
        if (user.getPermission() == null || user.getPermission() != PERMISSION_ADMIN) {
            return Result.error("该账号没有管理员权限，无法登录后台");
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
}
