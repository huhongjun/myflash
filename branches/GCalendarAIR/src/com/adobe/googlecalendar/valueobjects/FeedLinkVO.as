/*
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the as3googlecalendarlib.
 *
 * The Initial Developer of the Original Code is
 * Sujit Reddy G (http://sujitreddyg.wordpress.com/).
 * Portions created by the Initial Developer are Copyright (C) 2008
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
*/
package com.adobe.googlecalendar.valueobjects
{
	/**
	 * Schema: http://code.google.com/apis/gdata/elements.html#gdFeedLink
	 */
	import mx.collections.ArrayCollection;
	
	public class FeedLinkVO
	{
		public var countHint:String;
		public var href:String;
		public var readOnly:String;
		public var rel:String;
		
		//we dont have this element defined
		//this will contain multiple Entry child elements
		public var feed:Object;
		
		public function FeedLinkVO()
		{
		}

	}
}