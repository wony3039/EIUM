package com.myspring.eium.hm.hm_p0007.controller;



import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.myspring.eium.hm.hm_p0007.service.HM_P0007_07Service;
import com.myspring.eium.hm.hm_p0007.vo.HM_P0007_07VO;




@Controller
public class HM_P0007_07ControllerImpl implements HM_P0007_07Controller {
	private static final Logger logger = LoggerFactory.getLogger(HM_P0007_07ControllerImpl.class);
	@Autowired
	HM_P0007_07Service hM_P0007_07Service;
	
	
	@Override
	@RequestMapping(value = "/hm/p0007/searchWorking_status.do", method = { RequestMethod.GET, RequestMethod.POST })
	@ResponseBody
	public Map searchWorking_status(HttpServletRequest request, HttpServletResponse response) throws Exception {
		request.setCharacterEncoding("utf-8");
		Map<String, Object> searchMap = new HashMap<String, Object>();
		Map<String, Object> resultMap = new HashMap<String, Object>(); 
		searchMap.put("x", request.getParameter("x"));
		
		
		List<HM_P0007_07VO> data = hM_P0007_07Service.searchList(searchMap);

        resultMap.put("Data", data);
        for(int i=0; i<data.size(); i++) {
        data.get(i);
        }
    	System.out.println("resultMap::::"+resultMap);
        return resultMap;
	}
	
	
	



}
