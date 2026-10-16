package com.example.springboottest.service;

import com.example.springboottest.common.Result;
import com.example.springboottest.entity.Honor;
import com.example.springboottest.entity.HotKeyword;
import com.example.springboottest.entity.Moment;

import java.util.List;
import java.util.Map;

/**
 * 首页服务：聚合展示数据 + 高光时刻搜索
 */
public interface HomeService {

    /** 首页聚合数据：荣誉卡、热门搜索词、全部高光时刻 */
    Result<Map<String, Object>> home();

    /** 搜索高光时刻：按年份/标题/描述/标签模糊匹配，关键词为空返回全部 */
    Result<Map<String, Object>> search(String keyword);

    /** 供内部/其他服务复用的查询方法 */
    List<Honor> listHonors();

    List<HotKeyword> listHotKeywords();

    List<Moment> listMoments(String keyword);
}
