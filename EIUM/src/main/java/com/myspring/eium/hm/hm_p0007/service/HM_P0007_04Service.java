package com.myspring.eium.hm.hm_p0007.service;


import java.util.List;
import java.util.Map;

import org.springframework.dao.DataAccessException;

import com.myspring.eium.hm.hm_p0007.vo.HM_P0007_04VO;




public interface HM_P0007_04Service {
	 public List<HM_P0007_04VO> searchList(Map<String, Object> searchMap) throws DataAccessException;
     public void saveData(Map<String, String[]> dataMap, String user)  throws DataAccessException;

}
