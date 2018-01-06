package classes.internals 
{
	import classes.Items.Armors.Nothing;
	import flash.errors.IllegalOperationError;
	import classes.internals.LoggerFactory;
	import mx.logging.ILogger;
	
	/**
	 * A class providing utility methods to make serialization and deserialization easier.
	 */
	public class SerializationUtils 
	{
		private static const LOGGER:ILogger = LoggerFactory.getLogger(SerializationUtils);
		
		private static const SERIALIZATION_VERSION_PROPERTY:String = "serializationVersion";
		
		public function SerializationUtils() 
		{
			throw new IllegalOperationError("This class cannot be instantiated");
		}
		
		/**
		 * Serializes a Vector into an array.
		 * @param	vector to serialize
		 * @return a array containing the serialized vector
		 */
		public static function serializeVector(vector:Vector.<*>):Array {
			var serialized:Array = [];
			
			for each(var element:ISerializable in vector) {
				var obj:Array = [];
				serialized.push(obj);
				
				element.serialize(obj);
			}
			
			return serialized;
		}
		
		/**
		 * Deserializes a Array into a Vector of Serializable
		 * @param   destinationVector Vector where deserialized items will be written
		 * @param	serializedVector an Array containing the serialized vector
		 * @param	type of the serialized Vector
		 * @return a deserialized Vector
		 */
		public static function deserializeVector(destinationVector:Vector.<*>, serializedVector:Array, type:Class):void {
			// 'is' will only work on an instance
			if (!(new type() is ISerializable)) {
				throw new ArgumentError("Type must implement Serializable");
			}
			
			if (destinationVector === null) {
				throw new ArgumentError("Destination Vector cannot be null");
			}
			
			if (serializedVector === null) {
				throw new ArgumentError("Serialized Vector cannot be null");
			}
			
			for each(var element:Object in serializedVector) {
				var instance:ISerializable = new type();
				instance.deserialize(element);
				destinationVector.push(instance);
			}
		}
		
		
		/**
		 * Serializes a Vector into an array using AMF.
		 * @param	vector to serialize
		 * @return a array containing the serialized vector
		 */
		public static function serializeVectorWithAMF(vector:Vector.<ISerializableAMF>):Array {
			var serialized:Array = [];
			
			for each(var element:ISerializableAMF in vector) {
				serialized.push(element);
			}
			
			return serialized;
		}
		
		/**
		 * Deserializes a Array into a Vector using AMF
		 * @param	serializedVector an Array containing the serialized vector
		 * @param	type of the serialized Vector
		 * @return a deserialized Vector
		 */
		public static function deserializeVectorWithAMF(serializedVector:Array, type:Class):Vector.<ISerializableAMF> {
			// 'is' will only work on an instance
			if (!(new type() is ISerializableAMF)) {
				throw new ArgumentError("Type must implement SerializableAMF");
			}
			
			var deserialized:Vector.<ISerializableAMF> = new Vector.<ISerializableAMF>();
			
			for each(var element:Object in serializedVector) {
				deserialized.push(element as type);
			}
			
			return deserialized;
		}
		
		/**
		 * Casts a vector from one type to another. DOES NO VALIDATION.
		 * @param	destinationVector vector where casted elements will be put
		 * @param	sourceVector where elements for casting will be read from
		 * @param	destinationType the class to cast to
		 */
		public static function castVector(destinationVector:*, sourceVector:*, destinationType:Class):void {
			/**
			 * If anyone has a better idea, i'm all ears.
			 * Implement your solution and see if the tests pass.
			 */
			
			for each(var element:* in sourceVector) {
				destinationVector.push(element as destinationType);
			}
		}
		
		/**
		 * Get the serialization version from the object, if any.
		 * @param	relativeRootObject that possibly contains a serialization version
		 * @return the serialization version, or 0 if no version is found
		 */
		public static function serializationVersion(relativeRootObject:*):int {
			return relativeRootObject[SERIALIZATION_VERSION_PROPERTY];
		}
		
		/**
		 * Check the version of the serialized data and compare it with the current version.
		 * @param	relativeRootObject object that contains serialized data
		 * @return true if the serialized version is compatible with the current verison
		 */
		public static function serializedVersionCheck(relativeRootObject:*, expectedVersion:int):Boolean {
			var version:int = SerializationUtils.serializationVersion(relativeRootObject);
			
			if (version > expectedVersion) {
				LOGGER.error("Serialized version is {0}, but the current version is {1}. Backward compatibility is not guaranteed!", version, expectedVersion);
				return false;
			}else{
				LOGGER.debug("Serialized version is {0}", version);
			}
			
			return true;
		}
		
		/**
		 * Check that the passed object is defined.
		 * Will initalize with a empty array if undefined or null.
		 * If the object is defined, then it will be returned.
		 * @param	object to check and initialize
		 * @return a valid object. Needed because of how ActionScript handles references
		 */
		public static function initializeObject(object:*):* {
			if (object === undefined || object === null) {
				object = [];
			}
			
			return object;
		}
	}
}
