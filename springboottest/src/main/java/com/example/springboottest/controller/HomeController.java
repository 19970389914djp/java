package com.example.springboottest.controller;

import com.example.springboottest.common.Result;
import com.example.springboottest.service.HomeService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 首页接口：聚合展示数据 / 高光时刻搜索
 */
@RestController
@RequestMapping("/api")
public class HomeController {

    private final HomeService homeService;

    public HomeController(HomeService homeService) {
        this.homeService = homeService;
    }

    /** 首页聚合数据：GET /api/home → { honors, hotKeywords, moments } */
    @GetMapping("/home")
    public Result<Map<String, Object>> home() {
        return homeService.home();
    }

    /** 搜索高光时刻：GET /api/search?keyword=xxx（keyword 为空返回全部） */
    @GetMapping("/search")
    public Result<Map<String, Object>> search(@RequestParam(required = false) String keyword) {
        return homeService.search(keyword);
    }
}
