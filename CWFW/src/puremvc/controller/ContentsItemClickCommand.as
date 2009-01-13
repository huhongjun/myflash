package puremvc.controller
{
	import mx.controls.Tree;
	//import mx.utils.ObjectUtil;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import puremvc.ApplicationFacade;
	import puremvc.model.utils.CurrentInfo;
	import puremvc.model.utils.ModuleLocator;
	import puremvc.model.utils.XmlResource;
	import puremvc.model.vo.SectionVO;
	import puremvc.view.ContentsMediator;

	public class ContentsItemClickCommand extends SimpleCommand
	{
		override public function execute(note:INotification):void
		{
			var selectedItem:Object=note.getBody();
			var path:String;
			var currInfo:CurrentInfo=CurrentInfo.getInstance();	
			var treeContents:Tree=ContentsMediator(facade.retrieveMediator(ContentsMediator.NAME)).treeContents;					
			
			if(treeContents.getParentItem(selectedItem)==null)
			{//单章
				path=selectedItem.vo.path;
				sendNotification(ApplicationFacade.SINGLE_CHAPTER,selectedItem.name);
				currInfo.setCurrentChapter(selectedItem.vo);
				currInfo.setCurrentSection(null);				
			}
			else
			{//节	
				path=selectedItem.path;
				//if(ObjectUtil.compare(treeContents.getParentItem(selectedItem).vo,currInfo.getCurrentChapter(),0)!=0)
				if(treeContents.getParentItem(selectedItem).vo.id!=currInfo.getCurrentChapter().id)
				{
					sendNotification(ApplicationFacade.CHAPTER_CHANGE,treeContents.getParentItem(selectedItem).name);
					currInfo.setCurrentChapter(treeContents.getParentItem(selectedItem).vo);
				}  
				//if(ObjectUtil.compare(selectedItem,currInfo.getCurrentSection(),0)!=0)
				if(currInfo.getCurrentSection()==null||selectedItem.id!=currInfo.getCurrentSection().id)
				{
					sendNotification(ApplicationFacade.SECTION_CHANGE,selectedItem.name);
					currInfo.setCurrentSection(selectedItem as SectionVO);
				} 				
			}
			//sendNotification(ApplicationFacade.SWF_LOAD,selectedItem.@path);	
			var noteData:Object=ModuleLocator.locate(selectedItem.hasOwnProperty("type")?selectedItem.type:"flash",path);  
        	sendNotification(noteData.noteType,noteData.noteBody); 
		}
	}
}