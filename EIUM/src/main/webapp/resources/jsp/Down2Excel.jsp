<%@ page language="java" contentType="text/html;charset=euc-kr" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.poi.poifs.dev.*" %>
<%@ page import="org.apache.poi.hssf.record.*" %>
<%@ page import="org.apache.poi.hssf.model.*" %>
<%@ page import="org.apache.poi.hssf.usermodel.*" %>
<%@ page import="org.apache.poi.hssf.util.*" %>
<%
    //====================================================================================================
    // [ ����� ȯ�� ���� #1 ]
    //====================================================================================================
    // Html �������� ���ڵ��� utf-8 �� �����Ǿ� ������ "isUTF8 = true;" �� �����Ͻʽÿ�.
    // ���� ������ �ѱ��� ������ �� ���� �ٲ� ���ʽÿ�.
    // LoadExcel.jsp �� ������ ������ �ٲ� �ֽʽÿ�.
    //====================================================================================================
	boolean isUTF8 = false;
	//boolean isUTF8 = true;

    //====================================================================================================
    // [ ����� ȯ�� ���� #2 ]
    //====================================================================================================
    // ������ ���Ե� �̹����� URL �� ���������� ����� ��찡 �����̶� �ִٸ� ����Ʈ�� �Ʒ� ������ ���� ������ �ֽʽÿ�.
    // ������ ���Ե� �̹����� ���������� ������� ������ �׳� �η� �νʽÿ�.
    //====================================================================================================
	String sWebRoot = "C:/apache-tomcat-6.0.16/webapps";
	//String sWebRoot = "";	


    //====================================================================================================
    // [ ����� ȯ�� ���� #3 ]
    //====================================================================================================
    // Ʈ�� �÷����� �������� �� �� ���ٿ��� �������� ���� ���� ����ϴ�.
    // ���� �� ��� �ٸ� ���ڸ� ����ϱ⸦ ���Ͻø� �Ʒ� �����ڵ� \u2026 (16��������) ��� �ٸ� ���ڸ� �Է��Ͻʽÿ�.
    //====================================================================================================
	//String sTreeChar = "";		// ������ �鿩����ó�� ��� Ʈ�����ڵ��� �ٴڴٴ� ����.
	//String sTreeChar = "\u119E";	// ��
	//String sTreeChar = "\u2500";	// ��
	String sTreeChar = "\u2026";	// ��


    //====================================================================================================
    // [ ����� ȯ�� ���� #4 ]
    //====================================================================================================
    // �⺻ ��Ʈ �̸��� ��Ʈ ũ�⸦ �����մϴ�.
    //====================================================================================================
	String defaultFontName = "Dotum";
	short defaultFontSize = 11;
	
// isDebug = true; // ���������
//FileOutputStream fos = new FileOutputStream("D:/receive_debug.txt");

	if(sWebRoot.equals(""))
	{
		sWebRoot = application.getRealPath("");
	}

	request.setCharacterEncoding("euc-kr");

	    try
	    {
	        //====================================================================================================
	        // �����ڷḦ �����մϴ�.
	        //====================================================================================================
			BufferedReader br = null;
			if(isUTF8)
			{
				br = new BufferedReader(new InputStreamReader(request.getInputStream(),"UTF-8"));
			}
			else
			{
				br = new BufferedReader(new InputStreamReader(request.getInputStream()));
			}

			int NewSheetNo = 0;
			String SheetNames = "";
			String str;
			String sHeader = "";
			String sData = "";
			String CellType = "";
			StringBuffer sbData = new StringBuffer();


			boolean isHeaderParse = true;

			while((str = br.readLine()) != null)
			{
				str += "\r\n";
				if(isHeaderParse) // ����� �м���
				{
					if(str.indexOf("\u007F")>=0 && str.indexOf("\u0005")>=0)
					{
						isHeaderParse = false;	// �������ʹ� ����Ÿ �м��ϱ�
						sHeader += str.substring(0,str.indexOf("\u0005"));
						sbData.append(str.substring(str.indexOf("\u0005")));
					}
					else
					{
						sHeader += str;
					}
				}
				else // ����Ÿ�� ����
				{
					sbData.append(str);
				}
			}
			br.close();
			sData = sbData+"";

	        //====================================================================================================
	        // ���� �ڷ��� ����κи� �����մϴ�.
	        //====================================================================================================
			sHeader = sHeader.substring(sHeader.indexOf("\u0004")+1);

	        //====================================================================================================
	        // ���� �ڷ��� ������ �κ��� �����մϴ�.(���۸����)
	        //====================================================================================================
			sData = sData.substring(0,sData.lastIndexOf("\u0005")+1);

			String LastBufferPack = "";
			LastBufferPack = sHeader +  sData;
//System.out.println(sHeader +  sData);

//fos.write(LastBufferPack.getBytes());

	        //====================================================================================================
	        // ��ũ���� �����մϴ�.
	        //====================================================================================================
	        HSSFWorkbook workbook = new HSSFWorkbook();

	        String[] SheetDatas = LastBufferPack.split("\u0003");

			int kLoop = 1;
			if(LastBufferPack.indexOf("\u0003")!=-1)
			{
				kLoop = SheetDatas.length-0;
			}

for(int k=0;k<kLoop;k++) //�ִ� n���� ��Ʈ�� ��ƹޱ� ����.
{

			sHeader = SheetDatas[k].substring(0,SheetDatas[k].indexOf("\u0005"));
			sData = SheetDatas[k].substring(SheetDatas[k].indexOf("\u0005"));
			SheetDatas[k] = "";

	        //====================================================================================================
	        // ���޹��� Down2Excel ���ڸ� �غ��մϴ�.
	        //====================================================================================================
			int arrSize = 0;
			String sPalette= getPropValue(sHeader, "Palette");
//fos.write(sPalette.getBytes());
			String sRowHeights = getPropValue(sHeader, "RowHeights");
			String sColVisibles = getPropValue(sHeader, "ColVisibles");
			String arrRowHeights[] = sRowHeights.split("\\|");
			String TheDownloadFileName = getPropValue(sHeader, "FileName");
			String TheSheetName = getPropValue(sHeader, "SheetName");
			String Merge = getPropValue(sHeader, "Merge");
			String ImageNoSeed = " "+getPropValue(sHeader, "ImageNoSeed");
			String RecordTypes = getPropValue(sHeader, "RecordTypes");
			String RecordFormats = getPropValue(sHeader, "RecordFormats");
			String ColWidths = getPropValue(sHeader, "ColWidths");
			String arrColVisibles[] = sColVisibles.split("\\|");
			String RecordOrgFormats = getPropValue(sHeader, "RecordOrgFormats");
			String arrColWidths[] = ColWidths.split("\\|");
			String arrRecordType[] = RecordTypes.split("\\|");
			String arrRecordFormat[] = RecordTypes.split("\\|");
			String arrRecordOrgFormat[] = RecordTypes.split("\\|");
			String arrRecordFormat2[] = RecordFormats.split("\\|");
			String arrRecordOrgFormat2[] = RecordOrgFormats.split("\\|");
			String arrRecordTypeNumeric[] = RecordTypes.split("\\|");
			String BaseDir = getPropValue(sHeader,"BaseDir");
			
			String TitleText = getPropValue(sHeader, "TitleText");//"����\u007F����2\u007F����3\u0005�ر�\u007F�ر�2\u007F�ر�3";
			String UserMerge = getPropValue(sHeader, "UserMerge");

//fos.write((" TitleText0 :"+TitleText+"\n").getBytes());
			TitleText = TitleText.replace("\u0002","\u0005");
			
//fos.write(("BASE:"+BaseDir+"\n").getBytes());
			
			BaseDir = sWebRoot.replace("\\","/")+BaseDir;

			int HeaderRows  = Integer.parseInt("0" + getPropValue(sHeader, "HeaderRows"));
			int DownHeader  = Integer.parseInt("0" + getPropValue(sHeader, "DownHeader"));
			int SheetDesign = Integer.parseInt("0" + getPropValue(sHeader, "SheetDesign"));

			String SheetFontName = getPropValue(sHeader,"SheetFontName");
			int ExcelFontSize = 0;
			int ExcelRowHeight = 0;
			int SheetFontSize = 0;
			int HeaderBackColor = 0;
			int DataBackColor = 0;
//			int SumBackColor = 0;

//			int SumStartRow = Integer.parseInt(getPropValue(sHeader,"SumStartRow"));
//			int SumEndRow = Integer.parseInt(getPropValue(sHeader,"SumEndRow"));

			if(SheetDesign==1)
			{
				SheetFontName = getPropValue(sHeader,"SheetFontName");
				ExcelFontSize = Integer.parseInt("0"+getPropValue(sHeader,"ExcelFontSize"));
				ExcelRowHeight = Integer.parseInt("0"+getPropValue(sHeader,"ExcelRowHeight"));
				SheetFontSize = Integer.parseInt("0"+getPropValue(sHeader,"SheetFontSize"));
				if(ExcelFontSize>0) 
				{
					SheetFontSize = ExcelFontSize;
				}
				HeaderBackColor = Integer.parseInt("0"+getPropValue(sHeader,"HeaderBackColor"));
				DataBackColor = Integer.parseInt("0"+getPropValue(sHeader,"DataBackColor"));
//				SumBackColor = Integer.parseInt("0"+getPropValue(sHeader,"SumBackColor"));
			}
			else
			{
				SheetFontName = "Dotum";
				SheetFontSize = 10;
			}
			
			int hSheetFontSize = SheetFontSize;
			if(hSheetFontSize<3)
			{
				hSheetFontSize = 10;
			}
			

	        //====================================================================================================
	        // �ٿ�ε� ���ϸ��� �����մϴ�.
	        //====================================================================================================
			if(TheDownloadFileName.indexOf(".xls")==-1)
			{
				TheDownloadFileName +=".xls";
				//TheDownloadFileName = java.net.URLEncoder.encode(TheDownloadFileName); //�ѱ����ϸ��������
			}

			if(k==0)
			{
				response.setHeader("Content-Type", "application/octet-stream");

				String sEncodingFileName = new String(TheDownloadFileName.getBytes("euc-kr"), "8859_1");
				response.setHeader("Content-Disposition", "attachment;filename=" + sEncodingFileName + ";");
				
				response.setHeader("Content-Description", "JSP Generated Data");
			}

	        //====================================================================================================
	        // ��ũ��Ʈ���� �����մϴ�.
	        //====================================================================================================
			if(TheSheetName=="")
			{
				TheSheetName ="sheet";
			}

	        //====================================================================================================
	        // ��ũ��Ʈ�� �غ��մϴ�.
	        //====================================================================================================
	        HSSFSheet sheet = null;

			//====================================================================================================
			// �⺻ �� ��Ÿ���� �����մϴ�.
			//====================================================================================================
			HSSFCellStyle styleTitle = workbook.createCellStyle();
			HSSFCellStyle styleHead = workbook.createCellStyle();
			HSSFCellStyle styleCol[] = new HSSFCellStyle[arrRecordType.length];
			
			HSSFCellStyle style[] = new HSSFCellStyle[arrRecordType.length*32];
			HSSFCellStyle styleHeadColor[] = new HSSFCellStyle[arrRecordType.length*32];

			for(int j=0;j<arrRecordType.length*32;j++)
			{
				style[j] = workbook.createCellStyle();
				styleHeadColor[j] = workbook.createCellStyle();
			}
						
			HSSFDataFormat df[] = new HSSFDataFormat[arrRecordType.length];
			for(int i=0;i<arrRecordType.length;i++)
			{
				styleCol[i] = workbook.createCellStyle();
				df[i] = workbook.createDataFormat();
				
				if("|AutoSum|AutoAvg|Int|Float|".indexOf("|"+arrRecordTypeNumeric[i]+"|")>-1)
				{
					arrRecordTypeNumeric[i] = "N"; //N �̸� ���� �����..
				}
				else if(arrRecordTypeNumeric[i].equals("Date"))
				{
					arrRecordTypeNumeric[i] = "D"; //���̸� ����,��� �ƴ�
				}
				else
				{
					arrRecordTypeNumeric[i] = ""; //���̸� ����,��� �ƴ�
				}
				
				arrRecordFormat[i] = "";
				if (i<arrRecordFormat2.length)
				{
					arrRecordFormat[i] = arrRecordFormat2[i];
				}

				arrRecordOrgFormat[i] = "";
				if (i<arrRecordOrgFormat2.length)
				{
					arrRecordOrgFormat[i] = arrRecordOrgFormat2[i];
				}
			}
			HSSFFont font = workbook.createFont();
        	HSSFPalette palette = workbook.getCustomPalette();

			if(SheetDesign==1)
			{
				if(!sPalette.trim().equals(""))
				{
					sPalette = " "+sPalette.trim();
					String pal[] = sPalette.split(" ");
					for(int i=1;i<pal.length && i<=0x30;i++)
					{
		        		palette.setColorAtIndex((short)(0x0F+i),(byte)Integer.parseInt(pal[i].substring(0,2),16),(byte)Integer.parseInt(pal[i].substring(2,4),16),(byte)Integer.parseInt(pal[i].substring(4,6),16)); //������
					}
				}
			}

			// ��� �⺻��Ÿ��
			SetDefaultStyle("TITLE","","","",styleTitle, df[0], font, SheetDesign, SheetFontSize, SheetFontName, getColorIndex(palette,255,255,255), defaultFontName, defaultFontSize);
			SetDefaultStyle("HEAD","","","",styleHead, df[0], font, SheetDesign, SheetFontSize, SheetFontName, getColorIndex(palette,((HeaderBackColor/256/256)%256),  ((HeaderBackColor/256)%256), (HeaderBackColor%256)), defaultFontName, defaultFontSize);

			// �÷��� ���� ����
			for(int i=0;i<arrRecordType.length;i++)
			{
				for(int j=0;j<32;j++)
				{
					SetDefaultStyle("HEAD",arrRecordType[i],arrRecordOrgFormat[i],arrRecordFormat[i], styleHeadColor[j], df[i], font, SheetDesign, SheetFontSize, SheetFontName, j, defaultFontName, defaultFontSize);
				}

				SetDefaultStyle("DATA",arrRecordType[i],arrRecordOrgFormat[i],arrRecordFormat[i], styleCol[i], df[i], font, SheetDesign, SheetFontSize, SheetFontName, getColorIndex(palette,255,255,255), defaultFontName, defaultFontSize);
				for(int j=0;j<32;j++)
				{
					SetDefaultStyle("DATA",arrRecordType[i],arrRecordOrgFormat[i],arrRecordFormat[i], style[i*32+j], df[i], font, SheetDesign, SheetFontSize, SheetFontName, j, defaultFontName, defaultFontSize);
				}
				
			}

			int sTitleRow = 0;
			
			if (!TitleText.equals(""))
			{
				sTitleRow = TitleText.split("\u0005").length;
				TitleText = "\u0005"+TitleText;
			}
			
			sData = TitleText+sData;
	        String[] lines = (sData+"").split("\u0005");
	        HSSFRow row = null;
	        //====================================================================================================
	        // ����Ÿ �� ǥ���մϴ�.
	        //====================================================================================================
	        for (int iR = 1; iR < lines.length; iR++)
	        {
//fos.write((iR+" Row :"+lines.length+"\n").getBytes());
	        
	        	// ù�׸�� ���׸��� ������
				if(iR % 65536 == 1)
				{
			        //====================================================================================================
			        // ��ũ��Ʈ�� �����մϴ�.
			        //====================================================================================================
			        sheet = workbook.createSheet();
			        long SheetNo = ((iR-1)/65536)+1;
			        if(SheetNo!=1)TheSheetName += SheetNo;

			        if(SheetNames.indexOf(TheSheetName)==-1) // ���ο� ��Ʈ��(�������� ���)
			        {
			        	workbook.setSheetName(NewSheetNo, TheSheetName);
			        }
			    	else // ��Ʈ�� �ߺ���
			    	{
			        	workbook.setSheetName(NewSheetNo, TheSheetName+"("+k+")");
			    	}

			        SheetNames += TheSheetName+"//"; //����ߴ� ��Ʈ���
			        NewSheetNo = NewSheetNo + 1;
        		}

				if(lines[iR].indexOf("\u0002")!=-1) // ���ڷ���� ����
				{
					lines[iR] = " ";
				}

			    String [] cells = lines[iR].split("\u007F");
	            row = sheet.createRow((iR-1)%65536);

				CellType = "TITLE";
				
				arrSize = arrRecordType.length;
				if(iR<=sTitleRow)
				{
					arrSize = cells.length;
				}
				
		        for (int iC = 0; iC < arrSize; iC++)
		        {
						HSSFCell cell = row.createCell((short) iC);
						// ����� ������ ��� ����
						if(iR <= sTitleRow)
						{
							cell.setCellStyle(styleTitle);
						}
						else if(sTitleRow < iR && iR<=HeaderRows+sTitleRow && DownHeader==1)
						{
							cell.setCellStyle(styleHead);
							CellType = "HEAD";
						}
						else
						{
								cell.setCellStyle(styleCol[iC]);
								CellType = "";
							}
							
		        	if (iC<cells.length)
		        	{
						if(CellType.equals("TITLE") || CellType.equals("HEAD") || arrRecordTypeNumeric[iC].equals("")) //���� ����,��¥�� �ƴ�.
						{
							// ����, ��¥�� ������ �Ϲ� ����
							cell.setCellType(HSSFCell.CELL_TYPE_STRING);
							if(CellType.equals("HEAD"))
							{
								cellWriteValueText(palette, styleHeadColor, SheetDesign==1,cell,0, cells[iC], sTreeChar);
							}
							else
							{
								cellWriteValueText(palette, style, SheetDesign==1,cell,iC, cells[iC], sTreeChar);
								
							}
						}
						else
						{
						    if(arrRecordTypeNumeric[iC].equals("D"))
						    {
									cell.setCellType(HSSFCell.CELL_TYPE_STRING);
									cells[iC]=cells[iC].replaceAll("\\/","-").replaceAll("\\.","-");
									cellWriteValue(palette, style,SheetDesign==1,cell,iC, cells[iC]);
									
						    }
							else
							{
								if(arrRecordTypeNumeric[iC].equals("N"))
								{
									try
									{
										cell.setCellType(HSSFCell.CELL_TYPE_NUMERIC);
										cellWriteValueNumeric(palette, style,SheetDesign==1,cell,iC, cells[iC]);
										
									}
									catch(NumberFormatException e)
									{
										try
										{
											cell.setCellType(HSSFCell.CELL_TYPE_STRING);
											cellWriteValue(palette, style,SheetDesign==1,cell,iC,cells[iC]);
											
										}
										catch(NumberFormatException e2)
										{
											cellWriteValue(palette, style,SheetDesign==1,cell,iC,"0");
										}
									}
								}
							}
						}
						
					    if(CellType.equals("")) // �̹����� ����� �հ迡�� ����
					    {
	
						    if(arrRecordType[iC].equals("Image") || arrRecordType[iC].equals("ImageText"))
						    {
							    if(ImageNoSeed.indexOf(" "+(iR-1-sTitleRow)+","+iC+" ")==-1)
							    {
								    drawImage(sheet, workbook,sWebRoot, iR, iC, BaseDir, cells[iC] );
	  							}
	
									if(arrRecordType[iC].equals("Image"))
									{
											cellWriteValue(palette, style,SheetDesign==1,cell,iC, "");
							    }
						    }
					    }
					}
					else
					{
						cellWriteValue(palette, style, SheetDesign==1,cell,iC, "");
					}
					
		    	} //for
		    	
	            if(iR>sTitleRow)
	            {
		            if((iR-sTitleRow)<arrRowHeights.length)
		            {
		            	row.setHeight((short)(40+20*Short.parseShort(arrRowHeights[iR-sTitleRow]))); // 20���� 1�ȼ��� ���Ʒ� 1�ȼ��� ���鿡 ���̸�ŭ ���� ����
		            }
		        }
		    	else
		    	{
	            	row.setHeight((short)(40+20*32)); // 20 ����Ʈ ������ 1�ȼ��� ���Ʒ� 1�ȼ��� ���鿡 ���̸�ŭ ���� ����
		    	}
		    	
		    	if(ExcelRowHeight>0)
		    	{
	            	row.setHeight((short)(15*ExcelRowHeight)); // 15 Ʈ�� ����*1�ȼ�
		    	}

	        }

	        if(!Merge.equals(""))
	        {
		        String[] Merges = Merge.split(" ");
		        for (int iM = 0; iM < Merges.length; iM++)
		        {
		        	String[] mergeData = Merges[iM].split(",");

					Region region = new Region(Integer.parseInt(mergeData[0])+sTitleRow,(short)Integer.parseInt(mergeData[1]),Integer.parseInt(mergeData[2])+sTitleRow,(short)Integer.parseInt(mergeData[3]));
					sheet.addMergedRegion(region); //���� �����ϱ�
		        }
		   }
		   
	        if(!UserMerge.equals(""))
	        {
		        String[] Merges = UserMerge.split(" ");
		        for (int iM = 0; iM < Merges.length; iM++)
		        {
		        	String[] mergeData = Merges[iM].split(",");

					Region region = new Region(Integer.parseInt(mergeData[0]),(short)Integer.parseInt(mergeData[1]),Integer.parseInt(mergeData[0])+Integer.parseInt(mergeData[2])-1,(short)(Integer.parseInt(mergeData[1])+Integer.parseInt(mergeData[3])-1));
					sheet.addMergedRegion(region); //���� �����ϱ�
		        }
		   }

    // �÷��� �ݿ�
    double cWidthRatio = 36.5764447695684;
    for (int iC = 0; iC < arrRecordType.length; iC++)
    {
		if(arrColVisibles[iC].equals("0"))
		{
    		sheet.setColumnWidth(iC,0);
		}
		else
		{
	    	sheet.setColumnWidth(iC,(int)(cWidthRatio * Integer.parseInt("0"+arrColWidths[iC]) * SheetFontSize / 10 * 1.2)); // �׸��� �Ƚǰ� �����ȼ��� ���� ���¿��� ��Ʈ�� ũ�⿡ �����
		}		
    }

	
} // sheet

	        //====================================================================================================
	        // Client �� �����մϴ�.
	        //====================================================================================================
			out.clear();
			out = pageContext.pushBody();

			ServletOutputStream out2 = response.getOutputStream();
			workbook.write(out2);
			out2.flush();
		}
		catch(FileNotFoundException ex){
			System.out.println("FileNotFoundException : " + ex);
		}
		catch(IOException ioe){
			ioe.printStackTrace();
//fos.write(ioe.toString().getBytes());
    } catch (Exception e) {
//fos.write(e.toString().getBytes());
			e.printStackTrace();
    }
//fos.close();
%>

<%!

// �Լ� �߰�
private void cellWriteValue(HSSFPalette palette, HSSFCellStyle[] style , boolean SheetDesign,HSSFCell cell, int iC, String iData) throws Exception
{
	String iColor = "";
	if(iData.indexOf("\u0006")>-1)
	{
		iColor = iData.substring(iData.indexOf("\u0006")+1);
		iData = iData.substring(0,iData.indexOf("\u0006"));
		if(iColor.length()>=6)
		{
			cell.setCellStyle(style[iC*32+getColorIndex(palette,Integer.parseInt(iColor.substring(0,2),16),Integer.parseInt(iColor.substring(2,4),16),Integer.parseInt(iColor.substring(4,6),16))]);
		}
	}

	cell.setCellValue(iData);
}
private void cellWriteValueNumeric(HSSFPalette palette, HSSFCellStyle[] style, boolean SheetDesign, HSSFCell cell, int iC, String iData) throws Exception
{
	String iColor = "";
	if(iData.indexOf("\u0006")>-1)
	{
		iColor = iData.substring(iData.indexOf("\u0006")+1);
		iData = iData.substring(0,iData.indexOf("\u0006"));
		if(iColor.length()>=6)
		{
			cell.setCellStyle(style[iC*32+getColorIndex(palette,Integer.parseInt(iColor.substring(0,2),16),Integer.parseInt(iColor.substring(2,4),16),Integer.parseInt(iColor.substring(4,6),16))]);
		}
	}
	cell.setCellValue(Double.parseDouble(iData.replace(",","")));
}
private void cellWriteValueText(HSSFPalette palette, HSSFCellStyle[] style,  boolean SheetDesign,HSSFCell cell, int iC, String iData, String sTreeChar) throws Exception
{

	String iColor = "";
	if(iData.indexOf("\u0006")>-1)
	{
		iColor = iData.substring(iData.indexOf("\u0006")+1);
		iData = iData.substring(0,iData.indexOf("\u0006"));
		if(iColor.length()>=6)
		{
			cell.setCellStyle(style[iC*32+getColorIndex(palette,Integer.parseInt(iColor.substring(0,2),16),Integer.parseInt(iColor.substring(2,4),16),Integer.parseInt(iColor.substring(4,6),16))]);
		}
	}


	cell.setCellValue(iData.replaceAll("\r\n","\n").replaceAll("\u0001",sTreeChar));
}

private Short getColorIndex(HSSFPalette pallete, int R, int G, int B) throws Exception
{
	HSSFColor color = pallete.findSimilarColor(R,G,B);
	if(color==null)
	{
		return HSSFColor.WHITE.index;
	}
	else
	{
		return color.getIndex();
	}
}

private void drawImage(HSSFSheet sheet, HSSFWorkbook wb, String sWebRoot, int R, int C, String BaseDir, String url ) throws IOException
{
	File f = null;
	int result = 0;
	
	String ImageFilePath = "";
	
	if(url.indexOf("\u0006")>-1)
	{
		url = url.substring(0,url.indexOf("\u0006"));
	}
	
	
	if("http".equals((url+"    ").substring(0,4)))
	{
		url = url.substring(url.indexOf("://")+3);
		url = url.substring(url.indexOf("/"));
	}

	if("/".equals((url+" ").substring(0,1)))
	{
		url = sWebRoot + url;
	    ImageFilePath = url;
	}
	else
	{
	    ImageFilePath = BaseDir+url;
	}

    f = new File(ImageFilePath);

    if(f!=null)
	{
	    if(f.length()>0)
	    {
	    
		    HSSFPatriarch patriarch = sheet.createDrawingPatriarch();
		    HSSFClientAnchor anchor;
		    anchor = new HSSFClientAnchor(15,15,0,200,(short)C,(R-1),(short)(C+1),(R-1)); // �̹��� ũ�������� ���⼭..
		    anchor.setAnchorType( 2 );
		    try{
		    patriarch.createPicture(anchor, loadPicture(ImageFilePath, wb )); // ���� �� �̹���
		    	    }catch(FileNotFoundException e){}
		}
	}
	
	
}


private static int loadPicture( String path, HSSFWorkbook wb ) throws IOException
{
	int pictureIndex=-1;
	FileInputStream fis = null;
	ByteArrayOutputStream bos = null;

	try {
		fis = new FileInputStream(path);
			bos = new ByteArrayOutputStream( );
			int c;
			while ( (c = fis.read()) != -1) {
				bos.write( c );
			}
		pictureIndex = wb.addPicture( bos.toByteArray(), HSSFWorkbook.PICTURE_TYPE_JPEG  );
	} finally {
		if (fis != null) fis.close();
		if (bos != null) bos.close();
	}
	return pictureIndex;
}

String getPropValue(String Header, String prop) throws Exception
{
	int findS = 0;
	int findE = 0;

	findS = Header.indexOf("<"+prop+">");
	findE = Header.indexOf("</"+prop+">");

	if(findS != -1 && findE != -1) return Header.substring(findS+prop.length()+2,findE);		// ���� �±׸� �����ϰ� ����Ÿ�� ��������
	else return "";
}

void SetDefaultStyle(String RowType, String DataType, String DataOrgFormat, String DataFormat, HSSFCellStyle istyle, HSSFDataFormat df, HSSFFont font, int SheetDesign, int SheetFontSize, String SheetFontName, int BgColorIndex, String defaultFontName, short defaultFontSize)
{
	// �ܰ���
	if(!RowType.equals("TITLE"))
	{
		istyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);
		istyle.setBottomBorderColor(HSSFColor.BLACK.index);
		istyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);
		istyle.setLeftBorderColor(HSSFColor.BLACK.index);
		istyle.setBorderRight(HSSFCellStyle.BORDER_THIN);
		istyle.setRightBorderColor(HSSFColor.BLACK.index);
		istyle.setBorderTop(HSSFCellStyle.BORDER_THIN);
		istyle.setTopBorderColor(HSSFColor.BLACK.index);
	}
	
	// ���左 ��������
	istyle.setWrapText(true);
	istyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
	
	if(SheetDesign==1)
	{
		if(SheetFontSize>0)
		{
			font.setFontHeightInPoints((short)SheetFontSize);
		}
		if(!SheetFontName.equals(""))
		{
			font.setFontName(SheetFontName);
		}

		if(!RowType.equals("TITLE"))
		{
			istyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
			istyle.setFillForegroundColor((short)BgColorIndex);
		}
		istyle.setFont(font);
	}
	else
	{
		font.setFontHeightInPoints(defaultFontSize);
		font.setFontName(defaultFontName);
		istyle.setFont(font);
	}
	
	// �⺻ ����, �⺻ ����
	if(RowType.equals("HEAD") || RowType.equals("TITLE"))
	{
		istyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		istyle.setDataFormat(HSSFDataFormat.getBuiltinFormat("@"));
	}
	else
	{
		istyle.setAlignment(HSSFCellStyle.ALIGN_JUSTIFY);
		//styleSum.setDataFormat(HSSFDataFormat.getBuiltinFormat("@"));
	}
	
	
	// �÷��� ����
	if(!RowType.equals("HEAD"))
	{
		// ���� ��길 ������ �����ϱ� (AutoSum|AutoAvg|Int|Float)
		if("|AutoSum|AutoAvg|Int|Float|Integer|".indexOf("|"+DataType+"|")>-1 || "|Integer|Int|NullInteger|Float|NullFloat|".indexOf("|"+DataOrgFormat+"|")>-1)
		{
			istyle.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
		}
		
		// Integer ���� ������ ����Ÿ���� �ƴ� ������ ����� ��� ����
		if("|Integer|NullInteger|Float|NullFloat|Int|".indexOf("|"+DataOrgFormat+"|")>-1)
		{
			if("|AutoSum|AutoAvg|Int|Float|Integer|".indexOf("|"+DataType+"|")==-1)
			{
				DataFormat = "";
			}
		}



		// �÷��� ���� �����ϱ�
		if(DataType.equals("Date"))
		{
			istyle.setDataFormat(df.getFormat(DataFormat.replaceAll("\\/","-").replaceAll("\\.","-")));
//			istyle.setDataFormat(df.getFormat("yyyy-mm-dd"));
		}
		else if(DataFormat.equals("")) //���� ������ ��� �ؽ�Ʈ ����
		{
			//istyle.setDataFormat(df.getBuiltinFormat("@")); // @ �Ǵ� text
			istyle.setDataFormat(df.getBuiltinFormat("")); // @ �Ǵ� text
		}
		else if(!DataFormat.equals("")) //���� ����
		{
			DataFormat = DataFormat.replace("*","#").replace("#.","0.").replace("0.#","0.0");
			if("#".equals(DataFormat.substring(DataFormat.length()-1)))
			{
				if(DataFormat.indexOf(".")==-1)
				{
					DataFormat = DataFormat.substring(0,DataFormat.length()-1)+"0";
				}
			}
			istyle.setDataFormat(df.getFormat(DataFormat)); //����������
		}
		
		
	}
}
%>
