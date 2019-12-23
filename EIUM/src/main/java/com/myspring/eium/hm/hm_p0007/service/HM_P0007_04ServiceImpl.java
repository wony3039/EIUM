package com.myspring.eium.hm.hm_p0007.service;


import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.myspring.eium.hm.hm_p0007.dao.HM_P0007_04DAO;
import com.myspring.eium.hm.hm_p0007.vo.HM_P0007_04VO;






@Service
@Transactional(propagation = Propagation.REQUIRED)
public class HM_P0007_04ServiceImpl implements HM_P0007_04Service {
	@Autowired
	private HM_P0007_04DAO p0007_04DAO;

	@Override
	public List<HM_P0007_04VO> searchList(Map<String, Object> searchMap) throws DataAccessException {
		List<HM_P0007_04VO> list =  p0007_04DAO.searchList(searchMap); 
		return list;
	}
	
	@Override
	public void saveData(Map<String, String[]> dataMap, String u) throws DataAccessException {
		String[] status = dataMap.get("sStatus");
		int length = status.length; // row수
		int i = 0;
		String user = u;

		for(String str : status) {
			Map<String, String> row = getRow(dataMap, length, i, u);  // 현재 Index의 Row Map
			if("I".equals(str)) { // 추가
				p0007_04DAO.insertData(row);
			}else if("U".equals(str)) { // 수정
				p0007_04DAO.updateData(row);
			}else if("D".equals(str)) { // 삭제
				p0007_04DAO.deleteData(row);
			}
			i++;
		}
	}
		
		private Map<String, String> getRow(Map<String, String[]> dataMap, int length, int i, String u) {
			Map<String, String> row = new HashMap<String, String>();
			for(String name : dataMap.keySet()) {
				String[] data = dataMap.get(name);
				if(length == data.length) {
					row.put(name, data[i]);
					row.put("user", u);
				}
			}		
			return row;
		}

	
	

}
