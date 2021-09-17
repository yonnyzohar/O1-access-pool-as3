package  {
	
	public class Pool {
		var curIndex:int;
		var poolSize:int;
		var recentlyDiscardedIndex:int;
		var versionIncrement:int;
		
		var elementsStatus:Array;
		var recentlyDiscarded:Array;
		var totalUsageCount:Array;
		var pool:Array;
		var CLS:Class;
		
		
		public function Pool(_numElements : int, _CLS:Class) {
			
			CLS = _CLS;
			versionIncrement = 1000;
			curIndex = 0;//the current index of the pool
			recentlyDiscardedIndex = 0;
			
			pool = [];//the actual pool storing the elements
			elementsStatus = [];
			recentlyDiscarded = [];
			totalUsageCount = [];
			
			poolSize = _numElements;// store pool size as int
			for(var i:int = 0; i < _numElements; i++)
			{
				elementsStatus[i] = 0;
				totalUsageCount[i] = 0;
				pool[i] = new CLS();
			}
		}
		
		public function getAvaliable():int
		{
			var index:int;
			//if the recently discarded array is not empty, return the most recent
			//increment the number of times this handle was accloted as a new instance
			//mark the current element status as used
			//return the handle and the current usage count. the user needs to hold on to these two values for validation
			if(recentlyDiscardedIndex > 0)
			{
				index = recentlyDiscarded[recentlyDiscardedIndex];
				recentlyDiscardedIndex--;
				elementsStatus[index] = 1;
				totalUsageCount[index] += versionIncrement;
				return index + totalUsageCount[index];
			}
			
			index = curIndex;
			
			if (index >= poolSize)
			{
				//pool is full
				return -1;
			}
			
			elementsStatus[index] = 1;
			totalUsageCount[index] += versionIncrement;
			curIndex++;
			return index + totalUsageCount[index];
		}	
		
		//mark the current handle as used
		public function disposeElement( handle:int):void
		{
			var versionNum:int = handle / versionIncrement;
			versionNum *= versionIncrement;
			var index:int = handle - versionNum;
			recentlyDiscardedIndex++;
			recentlyDiscarded[recentlyDiscardedIndex] = index;
			elementsStatus[index] = 0;
		}
		
		//check if this handle is currently in use
		public function isOccupied( handle:int):int
		{
			var versionNum:int = handle / versionIncrement;
			versionNum *= versionIncrement;
			var index:int = handle - versionNum;
			
			if(index < 0 || index > poolSize)
			{
				return -1;
			}
			
			return elementsStatus[index]; // 0 is free, 1 is occupied
		}
		
		
		//check if this handle is valid (might be old handle currently assigned to differnt instance)
		//this will only return true if the element is in use and it is the same instance that the user thinks it is
		public function isValid( handle:int):Boolean
		{
			var versionNum:int = handle / versionIncrement;
			versionNum *= versionIncrement;
			var index:int = handle - versionNum;
			
			//if outside the bounds of the pool - invalaid
			if(index < 0 || index > poolSize)
			{
				return false;
			}
			
			var status: int = elementsStatus[index]; // 0 is free, 1 is occupied
			
			if(status == 1)
			{
				//if in use but not the same "version" as the one passed in, it is not valid
				if(totalUsageCount[index] != versionNum)
				{
					return false;
				}
				//it is same version and so is valid
				return true;
			}
			else
			{
				//index is not currently linked to live instance so it is invalid
				return false;
			}
		}
		
		//dangerous! expose this only to friend functions inside the infra!
		public function getElementActual( handle:int):Object{
			var versionNum:int = handle / versionIncrement;
			versionNum *= versionIncrement;
			var index:int = handle - versionNum;
			
			return pool[index];
		}


	}
	
}




    









