package com.myspring.eium.sm.sm_p0002.service;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.springframework.dao.DataAccessException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.myspring.eium.sm.sm_p0002.vo.SM_P0002VO;



public interface SM_P0002Service {
	 public List<SM_P0002VO> searchList(Map<String, Object> searchMap) throws DataAccessException;

	public void saveData(Map<String, String[]> dataMap)  throws DataAccessException ;

	public List<SM_P0002VO> searchList2(Map<String, Object> searchMap) throws DataAccessException;
}
