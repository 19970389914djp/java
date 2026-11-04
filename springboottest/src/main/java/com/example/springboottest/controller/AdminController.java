package com.example.springboottest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.springboottest.common.Result;
import com.example.springboottest.entity.Honor;
import com.example.springboottest.entity.HotKeyword;
import com.example.springboottest.entity.Moment;
import com.example.springboottest.mapper.HonorMapper;
import com.example.springboottest.mapper.HotKeywordMapper;
import com.example.springboottest.mapper.MomentMapper;
import com.example.springboottest.service.AdminService;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * 后台管理接口：登录 + 三张展示表（honor / moment / hot_keyword）的 CRUD
 *
 * 除登录外均需请求头 Authorization: <token>（内存 token，后端重启失效）
 */
@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final AdminService adminService;
    private final HonorMapper honorMapper;
    private final HotKeywordMapper hotKeywordMapper;
    private final MomentMapper momentMapper;

    public AdminController(AdminService adminService,
                           HonorMapper honorMapper,
                           HotKeywordMapper hotKeywordMapper,
                           MomentMapper momentMapper) {
        this.adminService = adminService;
        this.honorMapper = honorMapper;
        this.hotKeywordMapper = hotKeywordMapper;
        this.momentMapper = momentMapper;
    }

    /** 后台登录：{ "username": "邮箱", "password": "..." }，仅 permission=0 的管理员账号可登录 */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        return adminService.login(body.get("username"), body.get("password"));
    }

    /** 退出登录 */
    @PostMapping("/logout")
    public Result<Void> logout(@RequestHeader(value = "Authorization", required = false) String token) {
        adminService.logout(token);
        return Result.success("已退出登录");
    }

    // ==================== 生涯荣誉 honor ====================

    @GetMapping("/honors")
    public Result<List<Honor>> listHonors(@RequestHeader(value = "Authorization", required = false) String token) {
        Result<Void> auth = checkAuth(token);
        if (auth != null) return Result.error(auth.getMsg());
        return Result.success("获取荣誉列表成功",
                honorMapper.selectList(new LambdaQueryWrapper<Honor>().orderByAsc(Honor::getSortOrder)));
    }

    @PostMapping("/honor")
    public Result<Void> addHonor(@RequestHeader(value = "Authorization", required = false) String token,
                                 @RequestBody Honor honor) {
        Result<Void> auth = checkAuth(token);
        if (auth != null) return Result.error(auth.getMsg());
        if (honor.getLabel() == null || honor.getLabel().trim().isEmpty()) {
            return Result.error("荣誉名称不能为空");
        }
        if (honor.getValue() == null || honor.getValue().trim().isEmpty()) {
            return Result.error("荣誉数值不能为空");
        }
        if (honor.getSortOrder() == null) honor.setSortOrder(0);
        honorMapper.insert(honor);
        return Result.success("新增荣誉成功");
    }

    @PutMapping("/honor")
    public Result<Void> updateHonor(@RequestHeader(value = "Authorization", required = false) String token,
                                    @RequestBody Honor honor) {
        Result<Void> auth = checkAuth(token);
        if (auth != null) return Result.error(auth.getMsg());
        if (honor.getId() == null) return Result.error("缺少记录 ID");
        honorMapper.updateById(honor);
        return Result.success("更新荣誉成功");
    }

    @DeleteMapping("/honor/{id}")
    public Result<Void> deleteHonor(@RequestHeader(value = "Authorization", required = false) String token,
                                    @PathVariable Long id) {
        Result<Void> auth = checkAuth(token);
        if (auth != null) return Result.error(auth.getMsg());
        honorMapper.deleteById(id);
        return Result.success("删除荣誉成功");
    }

    // ==================== 高光时刻 moment ====================

    @GetMapping("/moments")
    public Result<List<Moment>> listMoments(@RequestHeader(value = "Authorization", required = false) String token) {
        Result<Void> auth = checkAuth(token);
        if (auth != null) return Result.error(auth.getMsg());
        return Result.success("获取高光时刻列表成功",
                momentMapper.selectList(new LambdaQueryWrapper<Moment>().orderByAsc(Moment::getSortOrder)));
    }

    @PostMapping("/moment")
    public Result<Void> addMoment(@RequestHeader(value = "Authorization", required = false) String token,
                                  @RequestBody Moment moment) {
        Result<Void> auth = checkAuth(token);
        if (auth != null) return Result.error(auth.getMsg());
        if (moment.getYear() == null || moment.getYear().trim().isEmpty()) {
            return Result.error("年份不能为空");
        }
        if (moment.getTitle() == null || moment.getTitle().trim().isEmpty()) {
            return Result.error("标题不能为空");
        }
        if (moment.getDescription() == null || moment.getDescription().trim().isEmpty()) {
            return Result.error("描述不能为空");
        }
        if (moment.getTags() == null) moment.setTags("");
        if (moment.getSortOrder() == null) moment.setSortOrder(0);
        momentMapper.insert(moment);
        return Result.success("新增高光时刻成功");
    }

    @PutMapping("/moment")
    public Result<Void> updateMoment(@RequestHeader(value = "Authorization", required = false) String token,
                                     @RequestBody Moment moment) {
        Result<Void> auth = checkAuth(token);
        if (auth != null) return Result.error(auth.getMsg());
        if (moment.getId() == null) return Result.error("缺少记录 ID");
        momentMapper.updateById(moment);
        return Result.success("更新高光时刻成功");
    }

    @DeleteMapping("/moment/{id}")
    public Result<Void> deleteMoment(@RequestHeader(value = "Authorization", required = false) String token,
                                     @PathVariable Long id) {
        Result<Void> auth = checkAuth(token);
        if (auth != null) return Result.error(auth.getMsg());
        momentMapper.deleteById(id);
        return Result.success("删除高光时刻成功");
    }

    // ==================== 热门搜索词 hot_keyword ====================

    @GetMapping("/hot-keywords")
    public Result<List<HotKeyword>> listHotKeywords(@RequestHeader(value = "Authorization", required = false) String token) {
        Result<Void> auth = checkAuth(token);
        if (auth != null) return Result.error(auth.getMsg());
        return Result.success("获取热词列表成功",
                hotKeywordMapper.selectList(new LambdaQueryWrapper<HotKeyword>().orderByAsc(HotKeyword::getSortOrder)));
    }

    @PostMapping("/hot-keyword")
    public Result<Void> addHotKeyword(@RequestHeader(value = "Authorization", required = false) String token,
                                      @RequestBody HotKeyword hotKeyword) {
        Result<Void> auth = checkAuth(token);
        if (auth != null) return Result.error(auth.getMsg());
        if (hotKeyword.getKeyword() == null || hotKeyword.getKeyword().trim().isEmpty()) {
            return Result.error("搜索词不能为空");
        }
        if (hotKeyword.getSortOrder() == null) hotKeyword.setSortOrder(0);
        hotKeywordMapper.insert(hotKeyword);
        return Result.success("新增热词成功");
    }

    @PutMapping("/hot-keyword")
    public Result<Void> updateHotKeyword(@RequestHeader(value = "Authorization", required = false) String token,
                                         @RequestBody HotKeyword hotKeyword) {
        Result<Void> auth = checkAuth(token);
        if (auth != null) return Result.error(auth.getMsg());
        if (hotKeyword.getId() == null) return Result.error("缺少记录 ID");
        hotKeywordMapper.updateById(hotKeyword);
        return Result.success("更新热词成功");
    }

    @DeleteMapping("/hot-keyword/{id}")
    public Result<Void> deleteHotKeyword(@RequestHeader(value = "Authorization", required = false) String token,
                                         @PathVariable Long id) {
        Result<Void> auth = checkAuth(token);
        if (auth != null) return Result.error(auth.getMsg());
        hotKeywordMapper.deleteById(id);
        return Result.success("删除热词成功");
    }

    // ==================== 公共 ====================

    /** token 校验：null 表示通过，否则返回未授权的 Result */
    private <T> Result<T> checkAuth(String token) {
        if (!adminService.checkToken(token)) {
            return Result.error("未登录或登录已过期，请重新登录");
        }
        return null;
    }
}
