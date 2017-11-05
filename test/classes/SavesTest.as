package classes{
	import classes.Scenes.Areas.Forest;
	import classes.Scenes.Exploration;
    import org.flexunit.asserts.*;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.*;
	import org.hamcrest.number.*;
	import org.hamcrest.object.*;
	import org.hamcrest.text.*;
	
	import flash.display.Stage;
	
	import classes.CoC;
	import classes.Scenes.Inventory;
	import classes.Saves;
	import classes.helper.StageLocator;
	import classes.GlobalFlags.kGAMECLASS;
	import classes.GlobalFlags.kFLAGS;
	
    public class SavesTest {
		private static const TEST_VERSION:String = "test";
		private static const TEST_SAVE_GAME:String = "test";
		
		private static const CLIT_LENGTH:Number = 5;
		private static const VAGINA_RECOVERY_PROGRESS:int = 6;
		
		private var player:Player;
        private var cut:Saves;
		
		[BeforeClass]
		public static function setUpClass():void {
			kGAMECLASS = new CoC(StageLocator.stage);
		}
		
        [Before]
        public function setUp():void {
			player = new Player();
			kGAMECLASS.player = player;
			kGAMECLASS.ver = TEST_VERSION;
			kGAMECLASS.version = TEST_VERSION;
				
			cut = new Saves(kGAMECLASS.gameStateDirectGet, kGAMECLASS.gameStateDirectSet);
			kGAMECLASS.inventory = new Inventory(cut);
			kGAMECLASS.forest = new Forest();
			kGAMECLASS.exploration = new Exploration(kGAMECLASS.forest);
			
        }  
     
        [Test] 
        public function testClitLengthSaved():void {
			player.createVagina();
			player.setClitLength(CLIT_LENGTH);
            cut.saveGame(TEST_SAVE_GAME, false);
			player.setClitLength(0);
			
			cut.loadGame(TEST_SAVE_GAME);
			
			assertThat(kGAMECLASS.player.getClitLength(), equalTo(CLIT_LENGTH));
        }
		  
		[Test] 
        public function testRecoveryProgressSaved():void {
			player.createVagina();
			player.vaginas[0].recoveryProgress = VAGINA_RECOVERY_PROGRESS;
            cut.saveGame(TEST_SAVE_GAME, false);
			player.vaginas[0].resetRecoveryProgress();
			
			cut.loadGame(TEST_SAVE_GAME);
			
			assertThat(kGAMECLASS.player.vaginas[0].recoveryProgress, equalTo(VAGINA_RECOVERY_PROGRESS));
        }
		
		[Test]
		public function forestExplorationSaved():void {
			kGAMECLASS.forest.explore();
			
			cut.saveGame(TEST_SAVE_GAME, false);
			kGAMECLASS.forest.explorationCount = 5;
			cut.loadGame(TEST_SAVE_GAME);
			
			assertThat(kGAMECLASS.forest.explorationCount, equalTo(1));
		}
		
		[Test]
		public function forestExplorationFlagRemoved():void {
			kGAMECLASS.forest.explorationCount = 5;
			cut.saveGame(TEST_SAVE_GAME, false);
			cut.loadGame(TEST_SAVE_GAME);
			
			assertThat(kGAMECLASS.flags[kFLAGS.TIMES_EXPLORED_FOREST], equalTo(0));
		}
    }
}
