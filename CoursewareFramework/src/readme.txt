�μ�ģ��Demo
���ṩ�������:1.�������-------index.html
	   		   2.SCORM��׼ҳ��--scorm�ļ�����
	   		   
1.index.swf����SwfLoader��ModulePlayerComponent�������.
  SwfLoader��������flash�����Ƭͷ;
  ModulePlayerComponent������̬���ز��������(Ŀǰ��flash��flv��ͼƬ������).
  
2.���ڱ������,ʵ�ֳ���ͽ������,��Ŀ¼��main1.swf��main2.swfΪ����flash����,Ŀǰֻ��"��һҳ"/"��һҳ"����������.
  ��Ҫ��config.xml�ļ��н��н��沼�ֺͿγ���������.

3.��ʵ��׼��scorm�μ�,Ҫ��imsmanifest.xml�ļ���������.����scoҳ�������scorm�ļ����µ�scoPlayer.swf�ļ���sco������������  �ü��ز�����������htmlҳ���ObjectԪ��������
  <param name="FlashVars" value="path=../assets/course/chapter01/unit02.jpg&type=image" />
  ������path��type���ɣ�·��ǰ���ϱ����"../",type�����ص��ļ�����:flash/flv/image.

ע��:scoҳ�����Ҫ����flv��Ƶ,�����ò���path�в��ܳ���"../",��·��������ȫ·�����flv�ļ�����scoPlayer.swf�����ļ�����Ȼ��path��д���·��.
