package com.myspring.eium.pm.pm_p0001.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.myspring.eium.pm.pm_p0001.dao.PM_P0001DAO;
import com.myspring.eium.pm.pm_p0001.vo.PM_P0001VO;

@Service
@Transactional(propagation = Propagation.REQUIRED)
public class PM_P0001ServiceImpl implements PM_P0001Service {
	@Autowired
	private PM_P0001DAO p0001DAO;

	@Override
	public List<PM_P0001VO> searchTypeList(Map<String, Object> searchMap) throws DataAccessException {
		List<PM_P0001VO> list =  p0001DAO.typeList(searchMap); 
		return list;
	}
	
	
	
	@Override
	public List<PM_P0001VO> paygrade_searchData(Map<String, Object> searchMap) throws DataAccessException {
		List<PM_P0001VO> list =  p0001DAO.paygradeList(searchMap); 
		return list;
	}
	@Override
	public List<PM_P0001VO> paydate_searchList(Map<String, Object> searchMap) throws DataAccessException {
		List<PM_P0001VO> list =  p0001DAO.paydate_searchList(searchMap); 
		return list;
	}
	
	@Override
	public List<PM_P0001VO> searchList(Map<String, Object> searchMap) throws DataAccessException {
		List<PM_P0001VO> list =  p0001DAO.searchList(searchMap); 
		return list;
	}
	
	@Override
	public List<PM_P0001VO> searchReceipt(Map<String, Object> searchMap) throws DataAccessException {
		List<PM_P0001VO> list =  p0001DAO.searchReceipt(searchMap); 
		return list;
	}

	@Override
	public void saveData(Map<String, String[]> dataMap, String user,String x, String y)  throws DataAccessException  {
		String[] status = dataMap.get("STATUS");
		int length = status.length; // row��
		int i = 0;
		
		for(String str : status) {
			Map<String, String> row = getRow(dataMap, length, i, user, x, y); // ���� Index�� Row Map
			if("I".equals(str)) { // �߰�
				p0001DAO.insertData(row);
			}else if("U".equals(str)) { // ����
				p0001DAO.updateData(row);
			}else if("D".equals(str)) { // ����
				p0001DAO.deleteData(row);
			}
			i++;
		}
	}
	
	private Map<String, String> getRow(Map<String, String[]> dataMap, int length, int index, String user, String x, String y) {
		Map<String, String> row = new HashMap<String, String>();
		for(String name : dataMap.keySet()) {
			String[] data = dataMap.get(name);
			if(length == data.length) {
				row.put(name, data[index]);
				row.put("user", user);
				row.put("x", x);
				row.put("y", y);


			}
		}		
		return row;
	}

	
}
