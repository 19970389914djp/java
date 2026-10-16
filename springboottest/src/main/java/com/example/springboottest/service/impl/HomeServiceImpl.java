package com.example.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.springboottest.common.Result;
import com.example.springboottest.entity.Honor;
import com.example.springboottest.entity.HotKeyword;
import com.example.springboottest.entity.Moment;
import com.example.springboottest.mapper.HonorMapper;
import com.example.springboottest.mapper.HotKeywordMapper;
import com.example.springboottest.mapper.MomentMapper;
import com.example.springboottest.service.HomeService;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 首页服务实现
 *
 * 三张表均为低频变更的展示型数据，量级很小（个位数），
 * 直接查库返回；后续数据量变大可加缓存。
 */
@Service
public class HomeServiceImpl implements HomeService {

    private final HonorMapper honorMapper;
    private final HotKeywordMapper hotKeywordMapper;
    private final MomentMapper momentMapper;

    public HomeServiceImpl(HonorMapper honorMapper,
                           HotKeywordMapper hotKeywordMapper,
                           MomentMapper momentMapper) {
        this.honorMapper = honorMapper;
        this.hotKeywordMapper = hotKeywordMapper;
        this.momentMapper = momentMapper;
    }

    @Override
    public Result<Map<String, Object>> home() {
        Map<String, Object> data = new HashMap<>();
        data.put("honors", listHonors());
        data.put("hotKeywords", listHotKeywords().stream()
                .map(HotKeyword::getKeyword)
                .collect(Collectors.toList()));
        data.put("moments", listMoments(null));
        return Result.success("获取首页数据成功", data);
    }

    @Override
    public Result<Map<String, Object>> search(String keyword) {
        List<Moment> moments = listMoments(keyword);
        Map<String, Object> data = new HashMap<>();
        data.put("moments", moments);
        data.put("total", moments.size());
        String msg = (keyword == null || keyword.trim().isEmpty())
                ? "获取全部高光时刻成功"
                : "搜索完成，命中 " + moments.size() + " 条";
        return Result.success(msg, data);
    }

    @Override
    public List<Honor> listHonors() {
        return honorMapper.selectList(
                new LambdaQueryWrapper<Honor>().orderByAsc(Honor::getSortOrder));
    }

    @Override
    public List<HotKeyword> listHotKeywords() {
        return hotKeywordMapper.selectList(
                new LambdaQueryWrapper<HotKeyword>().orderByAsc(HotKeyword::getSortOrder));
    }

    @Override
    public List<Moment> listMoments(String keyword) {
        LambdaQueryWrapper<Moment> wrapper = new LambdaQueryWrapper<Moment>()
                .orderByAsc(Moment::getSortOrder);
        if (keyword != null && !keyword.trim().isEmpty()) {
            String k = keyword.trim();
            // 年份 / 标题 / 描述 / 标签（逗号串）任意一个模糊命中即返回
            wrapper.and(w -> w.like(Moment::getYear, k)
                    .or().like(Moment::getTitle, k)
                    .or().like(Moment::getDescription, k)
                    .or().like(Moment::getTags, k));
        }
        return momentMapper.selectList(wrapper);
    }
}
