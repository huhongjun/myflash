
package puremvc.view
{
	import mx.collections.ArrayCollection;
	import mx.controls.Tree;
	import mx.events.ListEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import puremvc.ApplicationFacade;
	import puremvc.model.utils.CurrentInfo;
	import puremvc.model.vo.ChapterVO;
	//课程目录的"中介器"
	public class ContentsMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ContentsMediator";	
		
		public function ContentsMediator(viewComponent:Object)
		{
			super(NAME,viewComponent);
			treeContents.addEventListener(ListEvent.ITEM_CLICK,itemClick);
		} 
		
		private function initialize():void
		{
			//treeContents.labelField="@name";
			//treeContents.dataProvider=facade.retrieveProxy(CourseProxy.NAME).getData().Chapter as XMLList;	
			treeContents.labelField="name";				
			var chapterList:Array = CurrentInfo.getInstance().getCurrentCourse().chapters;			
        	for each(var chapter:ChapterVO in chapterList)
			{        					
				treeDataProvider.addItem({name:chapter.name,children:chapter.sections,vo:chapter});				
        	}									
			treeContents.callLater(expandAllNode);//初始展开所有节点			
		}
		
		public function expandAllNode():void
		{
			for each(var item:Object in treeDataProvider)
			{					
				treeContents.expandItem(item,true);
			}
		}
		
		private function itemClick(evt:ListEvent):void
		{			
			if(!treeContents.dataDescriptor.isBranch(evt.target.selectedItem))
			{							
				sendNotification(ApplicationFacade.CONTENTS_ITEM_CLICK,evt.target.selectedItem);				
				//trace("itemClick:"+evt.target.selectedItem.toXMLString());
			}			
		}
		
		override public function listNotificationInterests():Array
		{
			return [
						ApplicationFacade.TREE_INIT			
				   ];
		} 
				
		override public function handleNotification(note:INotification):void
		{
			 switch ( note.getName() ) 
			 {
			 	case ApplicationFacade.TREE_INIT : initialize(); break;				
             }
		} 
		
		public function get treeContents():Tree
		{
            return viewComponent.treeContents as Tree;
        }	
        
        public function get treeDataProvider():ArrayCollection
		{
            return viewComponent.treeDataProvider as ArrayCollection;
        }	  
	}
}