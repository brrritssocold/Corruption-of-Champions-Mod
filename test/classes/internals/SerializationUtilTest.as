package classes.internals
{
	import org.flexunit.asserts.*;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.*;
	import org.hamcrest.number.*;
	import org.hamcrest.object.*;
	import org.hamcrest.text.*;
	import org.hamcrest.collection.*;
	
	import classes.internals.ISerializable;
	import classes.internals.ISerializableAMF;
	
	public class SerializationUtilTest
	{
		private static const TEST_INSTANCES:int = 5;
		private static const SERIAL_VERSION:int = 2;
		
		private var testObject:Array;
		private var testVector:Vector.<ISerializable>;
		private var testAMFVector:Vector.<ISerializableAMF>;
		private var deserializedVector:Vector.<*>;
		private var serializedObject:*;
		
		private function buildVector(instances:int):void
		{
			for (var i:int = 0; i < instances; i++)
			{
				testVector.push(new SerializationDummy(i, i + 1));
			}
		}
		
		private function buildAmfVector(instances:int):void
		{
			for (var i:int = 0; i < instances; i++)
			{
				testAMFVector.push(new AMFSerializationDummy(i, i + 1));
			}
		}
		
		private function getTestObject():* {
			return SerializationUtils.serializeVector(testVector as Vector.<*>);
		}
		
		[Before]
		public function setUp():void
		{
			testObject = null;
			testVector = new Vector.<ISerializable>();
			testAMFVector = new Vector.<ISerializableAMF>();
			deserializedVector = new Vector.<*>();
			
			serializedObject = [];
			serializedObject.serializationVersion = SERIAL_VERSION;
			
			buildVector(TEST_INSTANCES);
			buildAmfVector(TEST_INSTANCES);
		}
		
		[Test]
		public function serializeVectorObjectSize():void
		{
			testObject = getTestObject();
			
			assertThat(testObject, arrayWithSize(TEST_INSTANCES));
		}
		
		[Test]
		public function serializeVectorLastObjectValue():void
		{
			testObject = getTestObject();
			
			assertThat(testObject[TEST_INSTANCES - 1], hasProperties({foo: TEST_INSTANCES - 1, bar: TEST_INSTANCES}));
		}
		
		[Test]
		public function serializeVectorWithAMFObjectSize():void
		{
			testObject = SerializationUtils.serializeVectorWithAMF(testAMFVector);
			
			assertThat(testObject, arrayWithSize(TEST_INSTANCES));
		}
		
		[Test]
		public function serializeVectorWithAMFLastObjectValue():void
		{
			testObject = SerializationUtils.serializeVectorWithAMF(testAMFVector);
			
			assertThat(testObject[TEST_INSTANCES - 1], instanceOf(AMFSerializationDummy));
		}
		
		[Test]
		public function deserializeVectorSize():void {
			testObject = getTestObject();
			
			SerializationUtils.deserializeVector(deserializedVector, testObject, SerializationDummy);
			
			assertThat(deserializedVector, arrayWithSize(TEST_INSTANCES));
		}
		
		[Test]
		public function deserializeVectorType():void {
			testObject = getTestObject();
			
			SerializationUtils.deserializeVector(deserializedVector,testObject, SerializationDummy);
			
			assertThat(deserializedVector[TEST_INSTANCES - 1], instanceOf(SerializationDummy));
		}
		
		[Test]
		public function deserializeVectorLastElementProperties():void {
			testObject = getTestObject();
			
			SerializationUtils.deserializeVector(deserializedVector, testObject, SerializationDummy);
			
			assertThat(deserializedVector[TEST_INSTANCES - 1], hasProperties({foo: TEST_INSTANCES - 1}));
			assertThat((deserializedVector[TEST_INSTANCES - 1] as SerializationDummy).getBar(), equalTo(TEST_INSTANCES));
		}
		
		[Test(expected="ArgumentError")]
		public function deserializeWithNonSerializableType():void {
			SerializationUtils.deserializeVector(new Vector.<*>(), new Array(), String);
		}
				
		[Test(expected="ArgumentError")]
		public function deserializeWithNullDestination():void {
			SerializationUtils.deserializeVector(null, new Array(), SerializationDummy);
		}
		
		[Test(expected="ArgumentError")]
		public function deserializeWithNullSource():void {
			SerializationUtils.deserializeVector(new Vector.<*>(), null, SerializationDummy);
		}
		
		[Test]
		public function castVectorCheckProperties():void {
			var destinationVector:Vector.<SerializationDummy> = new Vector.<SerializationDummy>();
			
			SerializationUtils.castVector(destinationVector, testVector, SerializationDummy);
			
			assertThat(destinationVector[TEST_INSTANCES - 1], hasProperties({foo: TEST_INSTANCES - 1}));
			assertThat(destinationVector[TEST_INSTANCES - 1].getBar(), equalTo(TEST_INSTANCES));
		}
		
		[Test]
		public function castVectorCheckType():void {
			var destinationVector:Vector.<SerializationDummy> = new Vector.<SerializationDummy>();
			
			SerializationUtils.castVector(destinationVector, testVector, SerializationDummy);
			
			assertThat(destinationVector[TEST_INSTANCES - 1], instanceOf(SerializationDummy));
		}
		
		[Test(expected="ArgumentError")]
		public function deserializeWithNonSerializableAMFType():void {
			SerializationUtils.deserializeVectorWithAMF(new Array(), String);
		}
		
		private function deserializeAMF():Vector.<ISerializableAMF> {
			testObject = SerializationUtils.serializeVectorWithAMF(testAMFVector);
			return SerializationUtils.deserializeVectorWithAMF(testObject, AMFSerializationDummy);
		}
		
		[Test]
		public function deserializeVectorWithAMFSize():void {
			var vector:Vector.<ISerializableAMF> = deserializeAMF();
			
			assertThat(vector, arrayWithSize(TEST_INSTANCES));
		}
		
		[Test]
		public function deserializeVectorWithAMFType():void {
			var vector:Vector.<ISerializableAMF> = deserializeAMF();
			
			assertThat(vector[TEST_INSTANCES - 1], instanceOf(ISerializableAMF));
		}
		
		[Test]
		public function deserializeVectorWithAMFProperty():void {
			var vector:Vector.<ISerializableAMF> = deserializeAMF();
			
			assertThat(vector[TEST_INSTANCES - 1], hasProperties({foo: TEST_INSTANCES - 1, bar: TEST_INSTANCES}));
		}
		
		[Test]
		public function serializationVersionWithNoProperty():void {
			serializedObject = [];
			
			assertThat(SerializationUtils.serializationVersion(serializedObject), equalTo(0));
		}
		
				
		[Test]
		public function serializationVersionWithProperty():void {
			assertThat(SerializationUtils.serializationVersion(serializedObject), equalTo(SERIAL_VERSION));
		}
				
		[Test]
		public function serializedVersionCheckSerializedGreater():void {
			assertThat(SerializationUtils.serializedVersionCheck(serializedObject, 1), equalTo(false));
		}
		
		[Test]
		public function serializedVersionCheckSerializedEqual():void {
			assertThat(SerializationUtils.serializedVersionCheck(serializedObject, 2), equalTo(true));
		}
		
		[Test]
		public function serializedVersionCheckSerializedLess():void {
			assertThat(SerializationUtils.serializedVersionCheck(serializedObject, 3), equalTo(true));
		}
		
		[Test]
		public function checkAndInitializeObjectNull():void {
			serializedObject = null;
			
			serializedObject = SerializationUtils.initializeObject(serializedObject);
			
			assertThat(serializedObject, notNullValue());
		}
		
		[Test]
		public function checkAndInitializeObjectUndefined():void {
			serializedObject = undefined;
			
			serializedObject = SerializationUtils.initializeObject(serializedObject);
			
			assertThat(serializedObject, notNullValue());
		}
		
		[Test]
		public function checkAndInitializeObjectDefined():void {
			serializedObject = SerializationUtils.initializeObject(serializedObject);
			
			assertThat(serializedObject, hasProperties({serializationVersion: SERIAL_VERSION}));
		}

		[Test(expected="RangeError")]
		public function serializedVersionCheckThrowErrorGreater():void {
			SerializationUtils.serializedVersionCheckThrowError(serializedObject, 1);
		}
		
		[Test]
		public function serializedVersionCheckThrowErrorEqual():void {
			SerializationUtils.serializedVersionCheckThrowError(serializedObject, 2);
		}
		
		[Test]
		public function serializedVersionCheckThrowErrorLess():void {
			SerializationUtils.serializedVersionCheckThrowError(serializedObject, 3);
		}
	}
}

import classes.internals.ISerializable;
import classes.internals.ISerializableAMF;
import flash.errors.IllegalOperationError;

class SerializationDummy implements ISerializable
{
	public var foo:int;
	private var bar:int;
	
	public function SerializationDummy(foo:int = -1, bar:int = -1)
	{
		this.foo = foo;
		this.bar = bar;
	}
	
	public function getBar():int {
		return this.bar;
	}
	
	public function serialize(relativeRootObject:*):void
	{
		relativeRootObject.foo = foo;
		relativeRootObject.bar = bar;
	}
	
	public function deserialize(relativeRootObject:*):void
	{
		this.foo = relativeRootObject.foo;
		this.bar = relativeRootObject.bar;
	}
	
	public function upgradeSerializationVersion(relativeRootObject:*, serializedDataVersion:int):void 
	{
		
	}
}

class AMFSerializationDummy implements ISerializableAMF
{
	public var foo:int;
	public var bar:int;
	
	public function AMFSerializationDummy(foo:int = -2, bar:int = -2)
	{
		this.foo = foo;
		this.bar = bar;
	}
}
