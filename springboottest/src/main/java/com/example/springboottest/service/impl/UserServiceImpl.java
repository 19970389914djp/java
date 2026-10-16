package com.example.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.springboottest.common.Result;
import com.example.springboottest.entity.User;
import com.example.springboottest.mapper.UserMapper;
import com.example.springboottest.service.UserService;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;

import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    /** 密码加盐值 */
    private static final String SALT = "@vue-login";

    /** 验证码有效期（毫秒）：5 分钟 */
    private static final long CODE_TTL = 5 * 60 * 1000L;

    /** 本地验证码存储：key = 邮箱/账号，value = [验证码, 过期时间戳] */
    private final Map<String, String[]> codeStore = new ConcurrentHashMap<>();

    private final SecureRandom random = new SecureRandom();

    @Override
    public Result<Map<String, String>> sendCode(String target) {
        if (target == null || target.trim().isEmpty()) {
            return Result.error("请先输入邮箱");
        }
        String email = target.trim();
        String code = String.format("%06d", random.nextInt(1000000));
        codeStore.put(email, new String[]{code, String.valueOf(System.currentTimeMillis() + CODE_TTL)});

        // 本地开发环境：未接入真实邮件服务，验证码打印到控制台并随响应返回，方便前端调试
        System.out.println("[验证码] " + email + " -> " + code + "（5 分钟内有效）");

        Map<String, String> data = new HashMap<>();
        data.put("code", code);
        return Result.success("验证码已发送（开发模式：验证码见响应 data.code 或后端控制台）", data);
    }

    @Override
    public Result<Void> register(String email, String password, String code) {
        if (email == null || email.trim().isEmpty()) {
            return Result.error("请输入邮箱");
        }
        email = email.trim();
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            return Result.error("邮箱格式不正确");
        }
        if (password == null || password.length() < 6 || password.length() > 20) {
            return Result.error("密码长度需为 6–20 位");
        }
        String codeError = checkCode(email, code);
        if (codeError != null) {
            return Result.error(codeError);
        }
        Long count = count(new LambdaQueryWrapper<User>().eq(User::getEmail, email));
        if (count > 0) {
            return Result.error("该邮箱已注册，请直接登录");
        }

        User user = new User();
        user.setEmail(email);
        user.setPassword(encrypt(password));
        user.setNickname(email.substring(0, email.indexOf('@')));
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        save(user);

        codeStore.remove(email);
        return Result.success("注册成功");
    }

    @Override
    public Result<Map<String, Object>> login(String account, String password, String code) {
        if (account == null || account.trim().isEmpty()) {
            return Result.error("请输入手机号或邮箱");
        }
        if (password == null || password.trim().isEmpty()) {
            return Result.error("请输入密码");
        }
        account = account.trim();

        String codeError = checkCode(account, code);
        if (codeError != null) {
            return Result.error(codeError);
        }

        User user = getOne(new LambdaQueryWrapper<User>().eq(User::getEmail, account));
        if (user == null) {
            return Result.error("账号不存在，请先注册");
        }
        if (!user.getPassword().equals(encrypt(password))) {
            return Result.error("密码错误");
        }

        codeStore.remove(account);

        // 生成简易登录令牌（学习项目，未接入 JWT，可按需替换）
        String token = UUID.randomUUID().toString().replace("-", "");

        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("id", user.getId());
        userInfo.put("email", user.getEmail());
        userInfo.put("nickname", user.getNickname());
        data.put("userInfo", userInfo);
        return Result.success("登录成功", data);
    }

    /** 校验验证码，校验失败返回错误信息，成功返回 null */
    private String checkCode(String target, String code) {
        if (code == null || code.trim().isEmpty()) {
            return "请输入验证码";
        }
        String[] entry = codeStore.get(target);
        if (entry == null) {
            return "请先获取验证码";
        }
        if (System.currentTimeMillis() > Long.parseLong(entry[1])) {
            codeStore.remove(target);
            return "验证码已过期，请重新获取";
        }
        if (!entry[0].equals(code.trim())) {
            return "验证码不正确";
        }
        return null;
    }

    /** MD5 + 盐加密 */
    private String encrypt(String password) {
        return DigestUtils.md5DigestAsHex((password + SALT).getBytes(StandardCharsets.UTF_8));
    }
}
