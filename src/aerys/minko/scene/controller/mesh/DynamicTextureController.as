package aerys.minko.scene.controller.mesh
{
	import aerys.minko.render.Viewport;
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.scene.controller.EnterFrameController;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.scene.node.Mesh;
	import aerys.minko.type.binding.DataProvider;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	
	/**
	 * The DynamicTextureController makes it possible to use Flash DisplayObjects
	 * as dynamic textures.
	 * 
	 * <p>
	 * The DynamicTextureController listen for the Scene.enterFrame signal and
	 * update the specified texture property of the targeted Meshes by rasterizing
	 * the source Flash DisplayObject.
	 * </p>
	 *   
	 * @author Jean-Marc Le Roux
	 * 
	 */
	public final class DynamicTextureController extends EnterFrameController
	{
		private var _data			: DataProvider		= null;
		
		private var _source			: DisplayObject		= null;
		private var _framerate		: Number			= 0.;
		private var _mipMapping		: Boolean			= false;
		private var _propertyName	: String			= null;
		private var _matrix			: Matrix			= null;
		
		private var _bitmapData	: BitmapData			= null;
		private var _texture	: TextureResource		= null;
		
		private var _lastDraw	: Number				= 0.;
		
		/**
		 * Create a new DynamicTextureController.
		 * 
		 * @param source The source DisplayObject to use as a dynamic texture.
		 * @param width The width of the dynamic texture.
		 * @param height The height of the dynamic texture.
		 * @param mipMapping Whether mip-mapping should be enabled or not. Default value is 'true'.
		 * @param framerate The frame rate of the dynamic texture. Default value is '30'.
		 * @param propertyName The name of the bindings property that should be set with the
		 * dynamic texture. Default value if 'diffuseMap'.
		 * @param matrix The Matrix object that shall be used when rasterizing the DisplayObject
		 * into the dynamic texture. Default value is 'null'.
		 * 
		 */
		public function DynamicTextureController(source			: DisplayObject,
												 width			: Number,
												 height			: Number,
												 mipMapping		: Boolean	= true,
												 framerate		: Number	= 30.,
												 propertyName	: String	= 'diffuseMap',
												 matrix			: Matrix	= null)
		{
			super();
			
			_source = source;
			_texture = new TextureResource(width, height);
			_framerate = framerate;
			_mipMapping = mipMapping;
			_propertyName = propertyName;
			_matrix = matrix;
			
			_data = new DataProvider();
			_data.setProperty(propertyName, _texture);
		}
		
		override protected function targetAddedHandler(ctrl		: EnterFrameController,
													   target	: ISceneNode) : void
		{
			super.targetAddedHandler(ctrl, target);
			
//			(target as Mesh).properties.setProperty(_propertyName, _texture);
			if (target is Scene)
				(target as Scene).bindings.addProvider(_data);
			else if (target is Mesh)
				(target as Mesh).bindings.addProvider(_data);
			else
				throw new Error();
		}
		
		override protected function targetRemovedHandler(ctrl	: EnterFrameController,
														 target	: ISceneNode) : void
		{
			super.targetRemovedHandler(ctrl, target);
			
//			(target as Mesh).properties.removeProperty(_propertyName);
			
			if (target is Scene)
				(target as Scene).bindings.removeProvider(_data);
			else if (target is Mesh)
				(target as Mesh).bindings.removeProvider(_data);
		}
		
		override protected function sceneEnterFrameHandler(scene	: Scene,
														   viewport	: Viewport,
														   target	: BitmapData,
														   time		: Number) : void
		{
			if (time - _lastDraw > 1000. / _framerate)
			{
				_lastDraw = time;
				
				_bitmapData ||= new BitmapData(_source.width, _source.height);
				_bitmapData.draw(_source, _matrix);
				
				_texture.setContentFromBitmapData(_bitmapData, _mipMapping);
			}
		}
	}
}