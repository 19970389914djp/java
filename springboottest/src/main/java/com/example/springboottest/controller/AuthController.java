package com.example.springboottest.controller;

import com.example.springboottest.common.Result;
import com.example.springboottest.service.UserService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 认证接口：发送验证码 / 注册 / 登录
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    /** 发送验证码：{ "target": "xxx@qq.com" } */
    @PostMapping("/send-code")
    public Result<Map<String, String>> sendCode(@RequestBody Map<String, String> body) {
        return userService.sendCode(body.get("target"));
    }

    /** 注册：{ "email": "...", "password": "...", "code": "..." } */
    @PostMapping("/register")
    public Result<Void> register(@RequestBody Map<String, String> body) {
        return userService.register(body.get("email"), body.get("password"), body.get("code"));
    }

    /** 登录：{ "account": "...", "password": "...", "code": "..." } */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        return userService.login(body.get("account"), body.get("password"), body.get("code"));
    }
}
